// ============================================================
// VOMAS - ESP32-A (MASTER)
// Version: 3.9 (FAST HTTP + REST API Endpoints)
// 
// FEATURES:
//   - Async HTTP POST to server (Core 0)
//   - REST API GET endpoints for calibration & status
//   - POST /VOMAS/angles - sends motion data to server
//   - GET /api/data - returns current motion data
//   - GET /api/calibrate - triggers calibration
//   - GET /api/status - returns calibration status
// ============================================================

#include "ICM_20948.h"
#include <esp_now.h>
#include <WiFi.h>
#include <HTTPClient.h>
#include <WiFiClientSecure.h>
#include <WebServer.h>
#include <Preferences.h>

#define SERIAL_PORT Serial
#define WIRE_PORT   Wire
#define AD0_IMU_A 0
#define AD0_IMU_B 1
#define I2C_SPEED 100000

ICM_20948_I2C imu_a;
ICM_20948_I2C imu_b;
Preferences prefs;
WebServer server(80);

// ============ WIFI CREDENTIALS ============
const char* WIFI_SSID = "K";
const char* WIFI_PASSWORD = "12345678";

// ============ REMOTE SERVER ENDPOINT ============
const char* SERVER_URL = "https://vomas-injury-recovery-app.onrender.com/VOMAS/angles";
const char* CALIBRATION_CHECK_URL = "https://vomas-injury-recovery-app.onrender.com/VOMAS/calibration-check";
const unsigned long POST_INTERVAL_MS = 500;  // 500ms = 2Hz (sufficient for rehab tracking)
const unsigned long CALIBRATION_POLL_INTERVAL_MS = 2000;  // Poll every 2 seconds
bool wifi_connected = false;

// ============ ASYNC HTTP TASK ============
TaskHandle_t httpTaskHandle = NULL;
SemaphoreHandle_t dataMutex;

// ============ CALIBRATION REQUEST FLAG ============
volatile bool calibrationRequested = false;

// Shared data structure for HTTP task
struct SharedMotionData {
  int sh_roll, sh_pitch, sh_yaw;
  int el_roll, el_pitch, el_yaw;
  int wr_roll, wr_pitch, wr_yaw;
  int pk_sh_r, pk_sh_p, pk_sh_y;
  int pk_el_r, pk_el_p, pk_el_y;
  int pk_wr_r, pk_wr_p, pk_wr_y;
  bool updated;
} sharedData = {0};

// HTTP statistics
volatile unsigned long http_success_count = 0;
volatile unsigned long http_fail_count = 0;
volatile unsigned long http_last_duration_ms = 0;

// ============ AXIS SIGN CONFIGURATION ============
const int SHOULDER_ROLL_SIGN  = 1;
const int SHOULDER_PITCH_SIGN = 1;
const int SHOULDER_YAW_SIGN   = 1;

const int ELBOW_ROLL_SIGN  = 1;
const int ELBOW_PITCH_SIGN = 1;
const int ELBOW_YAW_SIGN   = 1;

const int WRIST_ROLL_SIGN  = 1;
const int WRIST_PITCH_SIGN = 1;
const int WRIST_YAW_SIGN   = 1;

// ============ DRIFT SETTINGS ============
const unsigned long DRIFT_CHECK_INTERVAL_MS = 10000;
const double DRIFT_WARNING_THRESHOLD = 5.0;
const double STATIONARY_THRESHOLD = 2.0;

// ============ DATA STRUCTURES FOR ESP-NOW ============
typedef struct {
  double roll;
  double pitch;
  double yaw;
  unsigned long timestamp_ms;
  uint8_t imu_id;
  bool valid;
} WristDataPacket;

typedef struct {
  unsigned long master_time_ms;
  uint8_t sync_id;
} SyncPacket;

struct QuatData {
  double w, x, y, z;
  unsigned long timestamp_ms;
  bool valid;
};

QuatData imu_data[2];

// ============ WRIST DATA ============
struct WristData {
  double roll;
  double pitch;
  double yaw;
  unsigned long timestamp_ms;
  bool valid;
  unsigned long last_received_ms;
} wrist_data = {0, 0, 0, 0, false, 0};

// ============ CALIBRATION ============
struct CalibrationData {
  double neutral_a_w, neutral_a_x, neutral_a_y, neutral_a_z;
  double neutral_b_w, neutral_b_x, neutral_b_y, neutral_b_z;
  unsigned long calibration_time_ms;
  bool calibrated;
} cal_data = {1,0,0,0, 1,0,0,0, 0, false};

// ============ DRIFT TRACKING ============
struct DriftTracker {
  double last_sh_roll, last_sh_pitch, last_sh_yaw;
  double last_el_roll, last_el_pitch, last_el_yaw;
  unsigned long last_check_ms;
  bool was_stationary;
  int warning_count;
} drift;

// ============ VELOCITY TRACKER ============
struct VelocityTracker {
  double prev_angle;
  unsigned long prev_time_ms;
  double velocity;
  bool initialized;
  double alpha;
  double max_velocity;
  
  void init(double a = 0.15) {
    prev_angle = 0;
    prev_time_ms = millis();
    velocity = 0;
    initialized = false;
    alpha = a;
    max_velocity = 0;
  }
  
  void update(double angle) {
    unsigned long now = millis();
    
    if (!initialized) {
      prev_angle = angle;
      prev_time_ms = now;
      initialized = true;
      return;
    }
    
    double dt = (now - prev_time_ms) / 1000.0;
    if (dt < 0.001 || dt > 0.5) {
      prev_angle = angle;
      prev_time_ms = now;
      velocity = 0;
      return;
    }
    
    double delta = angle - prev_angle;
    if (delta > 180) delta -= 360;
    if (delta < -180) delta += 360;
    
    double instant_vel = delta / dt;
    velocity = alpha * instant_vel + (1 - alpha) * velocity;
    
    if (fabs(velocity) > max_velocity) max_velocity = fabs(velocity);
    
    prev_angle = angle;
    prev_time_ms = now;
  }
  
  void reset() {
    velocity = 0;
    initialized = false;
    max_velocity = 0;
  }
};

VelocityTracker v_sh_r, v_sh_p, v_sh_y;
VelocityTracker v_el_r, v_el_p, v_el_y;
VelocityTracker v_wr_r, v_wr_p, v_wr_y;

// ============ PEAK VELOCITY ============
const unsigned long PEAK_HOLD_MS = 3000;
unsigned long peak_window_start = 0;

double peak_sh_r = 0, peak_sh_p = 0, peak_sh_y = 0;
double peak_el_r = 0, peak_el_p = 0, peak_el_y = 0;
double peak_wr_r = 0, peak_wr_p = 0, peak_wr_y = 0;

void resetPeaks() {
  peak_sh_r = 0; peak_sh_p = 0; peak_sh_y = 0;
  peak_el_r = 0; peak_el_p = 0; peak_el_y = 0;
  peak_wr_r = 0; peak_wr_p = 0; peak_wr_y = 0;
  peak_window_start = millis();
}

void updatePeaks() {
  if (fabs(v_sh_r.velocity) > peak_sh_r) peak_sh_r = fabs(v_sh_r.velocity);
  if (fabs(v_sh_p.velocity) > peak_sh_p) peak_sh_p = fabs(v_sh_p.velocity);
  if (fabs(v_sh_y.velocity) > peak_sh_y) peak_sh_y = fabs(v_sh_y.velocity);
  
  if (fabs(v_el_r.velocity) > peak_el_r) peak_el_r = fabs(v_el_r.velocity);
  if (fabs(v_el_p.velocity) > peak_el_p) peak_el_p = fabs(v_el_p.velocity);
  if (fabs(v_el_y.velocity) > peak_el_y) peak_el_y = fabs(v_el_y.velocity);
  
  if (fabs(v_wr_r.velocity) > peak_wr_r) peak_wr_r = fabs(v_wr_r.velocity);
  if (fabs(v_wr_p.velocity) > peak_wr_p) peak_wr_p = fabs(v_wr_p.velocity);
  if (fabs(v_wr_y.velocity) > peak_wr_y) peak_wr_y = fabs(v_wr_y.velocity);
}

// Current angles
double sh_roll, sh_pitch, sh_yaw;
double el_roll, el_pitch, el_yaw;
double wr_roll, wr_pitch, wr_yaw;

// State
unsigned long packets_received = 0;
unsigned long last_sync_ms = 0;
bool output_enabled = true;

// ============ REST API HANDLERS ============

void addCorsHeaders() {
  server.sendHeader("Access-Control-Allow-Origin", "*");
  server.sendHeader("Access-Control-Allow-Methods", "GET, POST, OPTIONS");
  server.sendHeader("Access-Control-Allow-Headers", "Content-Type");
}

// GET /api/data - Returns current motion data
void handleGetData() {
  addCorsHeaders();
  
  String json = "{";
  json += "\"shoulder\":{";
  json += "\"roll\":{\"angle\":" + String((int)sh_roll) + ",\"speed\":" + String((int)peak_sh_r) + "},";
  json += "\"pitch\":{\"angle\":" + String((int)sh_pitch) + ",\"speed\":" + String((int)peak_sh_p) + "},";
  json += "\"yaw\":{\"angle\":" + String((int)sh_yaw) + ",\"speed\":" + String((int)peak_sh_y) + "}";
  json += "},";
  json += "\"elbow\":{";
  json += "\"roll\":{\"angle\":" + String((int)el_roll) + ",\"speed\":" + String((int)peak_el_r) + "},";
  json += "\"pitch\":{\"angle\":" + String((int)el_pitch) + ",\"speed\":" + String((int)peak_el_p) + "},";
  json += "\"yaw\":{\"angle\":" + String((int)el_yaw) + ",\"speed\":" + String((int)peak_el_y) + "}";
  json += "},";
  json += "\"wrist\":{";
  json += "\"roll\":{\"angle\":" + String((int)wr_roll) + ",\"speed\":" + String((int)peak_wr_r) + "},";
  json += "\"pitch\":{\"angle\":" + String((int)wr_pitch) + ",\"speed\":" + String((int)peak_wr_p) + "},";
  json += "\"yaw\":{\"angle\":" + String((int)wr_yaw) + ",\"speed\":" + String((int)peak_wr_y) + "}";
  json += "}";
  json += "}";
  
  server.send(200, "application/json", json);
}

// REMOVED: handleCalibrate() and handleStatus()
// Calibration is now triggered via NestJS backend polling
// ESP32 polls GET /VOMAS/calibration-check from the server

// OPTIONS handler for CORS preflight
void handleOptions() {
  addCorsHeaders();
  server.send(204);
}

// 404 handler
void handleNotFound() {
  addCorsHeaders();
  
  String json = "{";
  json += "\"error\":\"Not found\",";
  json += "\"available_endpoints\":[";
  json += "\"/api/data\",";
  json += "\"/api/calibrate\",";
  json += "\"/api/status\"";
  json += "]";
  json += "}";
  
  server.send(404, "application/json", json);
}

// ============ HTTP POST TASK (RUNS ON CORE 0) ============
void httpTask(void *parameter) {
  WiFiClientSecure client;
  client.setInsecure();
  client.setTimeout(5000);  // 5 second timeout for HTTPS
  
  HTTPClient http;
  http.setReuse(true);
  
  unsigned long lastPostTime = 0;
  bool connected = false;
  
  while (true) {
    if (WiFi.status() != WL_CONNECTED) {
      connected = false;
      vTaskDelay(pdMS_TO_TICKS(1000));
      continue;
    }
    
    if (millis() - lastPostTime < POST_INTERVAL_MS) {
      vTaskDelay(pdMS_TO_TICKS(5));
      continue;
    }
    
    SharedMotionData localData;
    if (xSemaphoreTake(dataMutex, pdMS_TO_TICKS(10)) == pdTRUE) {
      localData = sharedData;
      sharedData.updated = false;
      xSemaphoreGive(dataMutex);
    } else {
      vTaskDelay(pdMS_TO_TICKS(5));
      continue;
    }
    
    String json = "{";
    json += "\"shoulder\":{";
    json += "\"roll\":{\"angle\":" + String(localData.sh_roll) + ",\"speed\":" + String(localData.pk_sh_r) + "},";
    json += "\"pitch\":{\"angle\":" + String(localData.sh_pitch) + ",\"speed\":" + String(localData.pk_sh_p) + "},";
    json += "\"yaw\":{\"angle\":" + String(localData.sh_yaw) + ",\"speed\":" + String(localData.pk_sh_y) + "}";
    json += "},";
    json += "\"elbow\":{";
    json += "\"roll\":{\"angle\":" + String(localData.el_roll) + ",\"speed\":" + String(localData.pk_el_r) + "},";
    json += "\"pitch\":{\"angle\":" + String(localData.el_pitch) + ",\"speed\":" + String(localData.pk_el_p) + "},";
    json += "\"yaw\":{\"angle\":" + String(localData.el_yaw) + ",\"speed\":" + String(localData.pk_el_y) + "}";
    json += "},";
    json += "\"wrist\":{";
    json += "\"roll\":{\"angle\":" + String(localData.wr_roll) + ",\"speed\":" + String(localData.pk_wr_r) + "},";
    json += "\"pitch\":{\"angle\":" + String(localData.wr_pitch) + ",\"speed\":" + String(localData.pk_wr_p) + "},";
    json += "\"yaw\":{\"angle\":" + String(localData.wr_yaw) + ",\"speed\":" + String(localData.pk_wr_y) + "}";
    json += "}}";
    
    unsigned long startTime = millis();
    
    if (!connected) {
      if (http.begin(client, SERVER_URL)) {
        http.addHeader("Content-Type", "application/json");
        http.addHeader("Connection", "keep-alive");
        connected = true;
      }
    }
    
    if (connected) {
      int httpCode = http.POST(json);
      http_last_duration_ms = millis() - startTime;
      
      if (httpCode > 0) {
        http_success_count++;
        http.getString();
      } else {
        http_fail_count++;
        connected = false;
        http.end();
      }
    }
    
    lastPostTime = millis();
    
    // ============ CALIBRATION POLLING (every 2s) ============
    static unsigned long lastCalibrationCheck = 0;
    if (millis() - lastCalibrationCheck >= CALIBRATION_POLL_INTERVAL_MS) {
      lastCalibrationCheck = millis();
      
      WiFiClientSecure calClient;
      calClient.setInsecure();
      calClient.setTimeout(5000);
      HTTPClient httpCal;
      
      if (httpCal.begin(calClient, CALIBRATION_CHECK_URL)) {
        int calCode = httpCal.GET();
        if (calCode == 200) {
          String response = httpCal.getString();
          if (response.indexOf("true") >= 0) {
            calibrationRequested = true;
            SERIAL_PORT.println(F("CALIBRATION POLL: Trigger received from server!"));
          }
        } else {
          SERIAL_PORT.print(F("CALIBRATION POLL: HTTP error: "));
          SERIAL_PORT.println(calCode);
        }
        httpCal.end();
      }
    }
    
    vTaskDelay(pdMS_TO_TICKS(1));
  }
}

// ============ UPDATE SHARED DATA ============
void updateSharedData() {
  if (xSemaphoreTake(dataMutex, pdMS_TO_TICKS(5)) == pdTRUE) {
    sharedData.sh_roll = (int)sh_roll;
    sharedData.sh_pitch = (int)sh_pitch;
    sharedData.sh_yaw = (int)sh_yaw;
    sharedData.el_roll = (int)el_roll;
    sharedData.el_pitch = (int)el_pitch;
    sharedData.el_yaw = (int)el_yaw;
    sharedData.wr_roll = (int)wr_roll;
    sharedData.wr_pitch = (int)wr_pitch;
    sharedData.wr_yaw = (int)wr_yaw;
    sharedData.pk_sh_r = (int)peak_sh_r;
    sharedData.pk_sh_p = (int)peak_sh_p;
    sharedData.pk_sh_y = (int)peak_sh_y;
    sharedData.pk_el_r = (int)peak_el_r;
    sharedData.pk_el_p = (int)peak_el_p;
    sharedData.pk_el_y = (int)peak_el_y;
    sharedData.pk_wr_r = (int)peak_wr_r;
    sharedData.pk_wr_p = (int)peak_wr_p;
    sharedData.pk_wr_y = (int)peak_wr_y;
    sharedData.updated = true;
    xSemaphoreGive(dataMutex);
  }
}

// ============ NVS FUNCTIONS ============
void saveCalibrationToNVS() {
  prefs.begin("vomas_cal", false);
  prefs.putDouble("a_w", cal_data.neutral_a_w);
  prefs.putDouble("a_x", cal_data.neutral_a_x);
  prefs.putDouble("a_y", cal_data.neutral_a_y);
  prefs.putDouble("a_z", cal_data.neutral_a_z);
  prefs.putDouble("b_w", cal_data.neutral_b_w);
  prefs.putDouble("b_x", cal_data.neutral_b_x);
  prefs.putDouble("b_y", cal_data.neutral_b_y);
  prefs.putDouble("b_z", cal_data.neutral_b_z);
  prefs.putBool("valid", true);
  prefs.end();
  SERIAL_PORT.println(F("CALIBRATION: Saved to NVS"));
}

bool loadCalibrationFromNVS() {
  prefs.begin("vomas_cal", true);
  bool valid = prefs.getBool("valid", false);
  if (valid) {
    cal_data.neutral_a_w = prefs.getDouble("a_w", 1.0);
    cal_data.neutral_a_x = prefs.getDouble("a_x", 0.0);
    cal_data.neutral_a_y = prefs.getDouble("a_y", 0.0);
    cal_data.neutral_a_z = prefs.getDouble("a_z", 0.0);
    cal_data.neutral_b_w = prefs.getDouble("b_w", 1.0);
    cal_data.neutral_b_x = prefs.getDouble("b_x", 0.0);
    cal_data.neutral_b_y = prefs.getDouble("b_y", 0.0);
    cal_data.neutral_b_z = prefs.getDouble("b_z", 0.0);
    cal_data.calibrated = true;
    cal_data.calibration_time_ms = millis();
  }
  prefs.end();
  return valid;
}

void clearCalibrationFromNVS() {
  prefs.begin("vomas_cal", false);
  prefs.clear();
  prefs.end();
  cal_data.calibrated = false;
  SERIAL_PORT.println(F("CALIBRATION: Cleared"));
}

// ============ QUATERNION MATH ============
bool buildQuatFromDMP(const icm_20948_DMP_data_t &d, double &qw, double &qx, double &qy, double &qz) {
  if ((d.header & DMP_header_bitmap_Quat6) == 0) return false;
  
  double q1 = ((double)d.Quat6.Data.Q1) / 1073741824.0;
  double q2 = ((double)d.Quat6.Data.Q2) / 1073741824.0;
  double q3 = ((double)d.Quat6.Data.Q3) / 1073741824.0;
  double q0sq = 1.0 - ((q1*q1) + (q2*q2) + (q3*q3));
  if (q0sq < -0.01) return false;
  
  double q0 = (q0sq > 0.0) ? sqrt(q0sq) : 0.0;
  qw = q0; qx = q2; qy = q1; qz = -q3;

  double mag = sqrt(qw*qw + qx*qx + qy*qy + qz*qz);
  if (mag < 0.9 || mag > 1.1) return false;
  qw /= mag; qx /= mag; qy /= mag; qz /= mag;
  return true;
}

void quatMultiply(double aw, double ax, double ay, double az,
                  double bw, double bx, double by, double bz,
                  double &rw, double &rx, double &ry, double &rz) {
  rw = aw*bw - ax*bx - ay*by - az*bz;
  rx = aw*bx + ax*bw + ay*bz - az*by;
  ry = aw*by - ax*bz + ay*bw + az*bx;
  rz = aw*bz + ax*by - ay*bx + az*bw;
}

void quatConjugate(double w, double x, double y, double z, 
                   double &cw, double &cx, double &cy, double &cz) {
  cw = w; cx = -x; cy = -y; cz = -z;
}

void quatToEuler(double qw, double qx, double qy, double qz,
                 double &roll, double &pitch, double &yaw) {
  double sinr_cosp = 2.0 * (qw * qx + qy * qz);
  double cosr_cosp = 1.0 - 2.0 * (qx * qx + qy * qy);
  roll = atan2(sinr_cosp, cosr_cosp) * 180.0 / M_PI;
  
  double sinp = 2.0 * (qw * qy - qz * qx);
  if (fabs(sinp) >= 1.0)
    pitch = copysign(90.0, sinp);
  else
    pitch = asin(sinp) * 180.0 / M_PI;
  
  double siny_cosp = 2.0 * (qw * qz + qx * qy);
  double cosy_cosp = 1.0 - 2.0 * (qy * qy + qz * qz);
  yaw = atan2(siny_cosp, cosy_cosp) * 180.0 / M_PI;
}

void drainFIFO(ICM_20948_I2C &imu) {
  uint16_t fifo_count = 0;
  imu.getFIFOcount(&fifo_count);
  while (fifo_count > 30) {
    icm_20948_DMP_data_t dummy;
    imu.readDMPdataFromFIFO(&dummy);
    imu.getFIFOcount(&fifo_count);
  }
}

// ============ ANGLE CALCULATIONS ============
void getShoulderAngles(double &roll, double &pitch, double &yaw) {
  if (!imu_data[0].valid) { roll = pitch = yaw = 0; return; }
  
  double cw, cx, cy, cz;
  quatConjugate(cal_data.neutral_a_w, cal_data.neutral_a_x, 
                cal_data.neutral_a_y, cal_data.neutral_a_z, cw, cx, cy, cz);
  
  double ow, ox, oy, oz;
  quatMultiply(imu_data[0].w, imu_data[0].x, imu_data[0].y, imu_data[0].z,
               cw, cx, cy, cz, ow, ox, oy, oz);
  
  double mag = sqrt(ow*ow + ox*ox + oy*oy + oz*oz);
  if (mag > 1e-9) { ow /= mag; ox /= mag; oy /= mag; oz /= mag; }
  
  quatToEuler(ow, ox, oy, oz, roll, pitch, yaw);
  
  roll  *= SHOULDER_ROLL_SIGN;
  pitch *= SHOULDER_PITCH_SIGN;
  yaw   *= SHOULDER_YAW_SIGN;
}

void getElbowAngles(double &roll, double &pitch, double &yaw) {
  if (!imu_data[0].valid || !imu_data[1].valid) { roll = pitch = yaw = 0; return; }
  
  double cw, cx, cy, cz;
  quatConjugate(cal_data.neutral_a_w, cal_data.neutral_a_x,
                cal_data.neutral_a_y, cal_data.neutral_a_z, cw, cx, cy, cz);
  double qa_w, qa_x, qa_y, qa_z;
  quatMultiply(imu_data[0].w, imu_data[0].x, imu_data[0].y, imu_data[0].z,
               cw, cx, cy, cz, qa_w, qa_x, qa_y, qa_z);
  
  quatConjugate(cal_data.neutral_b_w, cal_data.neutral_b_x,
                cal_data.neutral_b_y, cal_data.neutral_b_z, cw, cx, cy, cz);
  double qb_w, qb_x, qb_y, qb_z;
  quatMultiply(imu_data[1].w, imu_data[1].x, imu_data[1].y, imu_data[1].z,
               cw, cx, cy, cz, qb_w, qb_x, qb_y, qb_z);
  
  quatConjugate(qa_w, qa_x, qa_y, qa_z, cw, cx, cy, cz);
  double rw, rx, ry, rz;
  quatMultiply(qb_w, qb_x, qb_y, qb_z, cw, cx, cy, cz, rw, rx, ry, rz);
  
  double mag = sqrt(rw*rw + rx*rx + ry*ry + rz*rz);
  if (mag > 1e-9) { rw /= mag; rx /= mag; ry /= mag; rz /= mag; }
  
  quatToEuler(rw, rx, ry, rz, roll, pitch, yaw);
  
  roll  *= ELBOW_ROLL_SIGN;
  pitch *= ELBOW_PITCH_SIGN;
  yaw   *= ELBOW_YAW_SIGN;
}

void getWristAngles(double &roll, double &pitch, double &yaw) {
  if (!wrist_data.valid) { roll = pitch = yaw = 0; return; }
  roll  = wrist_data.roll * WRIST_ROLL_SIGN;
  pitch = wrist_data.pitch * WRIST_PITCH_SIGN;
  yaw   = wrist_data.yaw * WRIST_YAW_SIGN;
}

// ============ DRIFT DETECTION ============
void checkDrift() {
  if (millis() - drift.last_check_ms < DRIFT_CHECK_INTERVAL_MS) return;
  
  bool stationary = (
    fabs(v_sh_r.velocity) < STATIONARY_THRESHOLD &&
    fabs(v_sh_p.velocity) < STATIONARY_THRESHOLD &&
    fabs(v_sh_y.velocity) < STATIONARY_THRESHOLD &&
    fabs(v_el_r.velocity) < STATIONARY_THRESHOLD &&
    fabs(v_el_p.velocity) < STATIONARY_THRESHOLD &&
    fabs(v_el_y.velocity) < STATIONARY_THRESHOLD
  );
  
  if (stationary && drift.was_stationary) {
    double sh_drift = sqrt(pow(sh_roll - drift.last_sh_roll, 2) +
                           pow(sh_pitch - drift.last_sh_pitch, 2) +
                           pow(sh_yaw - drift.last_sh_yaw, 2));
    double el_drift = sqrt(pow(el_roll - drift.last_el_roll, 2) +
                           pow(el_pitch - drift.last_el_pitch, 2) +
                           pow(el_yaw - drift.last_el_yaw, 2));
    
    if (sh_drift > DRIFT_WARNING_THRESHOLD || el_drift > DRIFT_WARNING_THRESHOLD) {
      drift.warning_count++;
      SERIAL_PORT.println();
      SERIAL_PORT.print(F("DRIFT_WARNING:")); SERIAL_PORT.print(drift.warning_count);
      SERIAL_PORT.print(F(" SH:")); SERIAL_PORT.print((int)sh_drift);
      SERIAL_PORT.print(F(" EL:")); SERIAL_PORT.println((int)el_drift);
    }
  }
  
  if (stationary) {
    drift.last_sh_roll = sh_roll; drift.last_sh_pitch = sh_pitch; drift.last_sh_yaw = sh_yaw;
    drift.last_el_roll = el_roll; drift.last_el_pitch = el_pitch; drift.last_el_yaw = el_yaw;
  }
  
  drift.was_stationary = stationary;
  drift.last_check_ms = millis();
}

// ============ ESP-NOW ============
void onDataReceived(const esp_now_recv_info *recv_info, const uint8_t *data, int len) {
  if (len == sizeof(WristDataPacket)) {
    WristDataPacket *packet = (WristDataPacket*)data;
    if (packet->imu_id == 2 && packet->valid) {
      wrist_data.roll = packet->roll;
      wrist_data.pitch = packet->pitch;
      wrist_data.yaw = packet->yaw;
      wrist_data.timestamp_ms = packet->timestamp_ms;
      wrist_data.valid = true;
      wrist_data.last_received_ms = millis();
      packets_received++;
    }
  }
}

void sendTimeSync() {
  if (millis() - last_sync_ms > 1000) {
    SyncPacket sync;
    sync.master_time_ms = millis();
    sync.sync_id = 0xFF;
    esp_now_send(NULL, (uint8_t*)&sync, sizeof(sync));
    last_sync_ms = millis();
  }
}

void checkWristConnection() {
  if (wrist_data.valid && (millis() - wrist_data.last_received_ms > 2000)) {
    wrist_data.valid = false;
    SERIAL_PORT.println(F("WARNING: Wrist timeout"));
  }
}

// ============ CALIBRATION ============
void calibrateZero() {
  output_enabled = false;
  
  SERIAL_PORT.println(F("\n========================================"));
  SERIAL_PORT.println(F("       CALIBRATION - ZERO AT REST       "));
  SERIAL_PORT.println(F("========================================\n"));
  SERIAL_PORT.println(F("POSITION: Arm straight, palm to thigh"));
  SERIAL_PORT.println(F("CALIBRATING IN 3 SECONDS...\n"));
  
  // Non-blocking 3-second wait (keeps WebServer alive if still running)
  unsigned long waitStart = millis();
  while (millis() - waitStart < 3000) {
    if (wifi_connected) server.handleClient();
    delay(10);
  }
  
  double sum_a_w=0, sum_a_x=0, sum_a_y=0, sum_a_z=0;
  double sum_b_w=0, sum_b_x=0, sum_b_y=0, sum_b_z=0;
  int n_a=0, n_b=0;
  
  SERIAL_PORT.print(F("SAMPLING"));
  
  for (int i = 0; i < 150; i++) {
    drainFIFO(imu_a); drainFIFO(imu_b);
    
    icm_20948_DMP_data_t da, db;
    imu_a.readDMPdataFromFIFO(&da);
    imu_b.readDMPdataFromFIFO(&db);
    
    double qw, qx, qy, qz;
    
    if (buildQuatFromDMP(da, qw, qx, qy, qz)) {
      sum_a_w += qw; sum_a_x += qx; sum_a_y += qy; sum_a_z += qz; n_a++;
    }
    if (buildQuatFromDMP(db, qw, qx, qy, qz)) {
      sum_b_w += qw; sum_b_x += qx; sum_b_y += qy; sum_b_z += qz; n_b++;
    }
    
    if (i % 30 == 0) SERIAL_PORT.print(".");
    delay(10);
  }
  SERIAL_PORT.println(F(" DONE"));
  
  bool success = true;
  
  if (n_a > 10) {
    cal_data.neutral_a_w = sum_a_w / n_a;
    cal_data.neutral_a_x = sum_a_x / n_a;
    cal_data.neutral_a_y = sum_a_y / n_a;
    cal_data.neutral_a_z = sum_a_z / n_a;
    double mag = sqrt(cal_data.neutral_a_w*cal_data.neutral_a_w + cal_data.neutral_a_x*cal_data.neutral_a_x +
                      cal_data.neutral_a_y*cal_data.neutral_a_y + cal_data.neutral_a_z*cal_data.neutral_a_z);
    cal_data.neutral_a_w /= mag; cal_data.neutral_a_x /= mag;
    cal_data.neutral_a_y /= mag; cal_data.neutral_a_z /= mag;
    SERIAL_PORT.print(F("IMU_A: OK (")); SERIAL_PORT.print(n_a); SERIAL_PORT.println(F(" samples)"));
  } else { SERIAL_PORT.println(F("IMU_A: FAILED")); success = false; }
  
  if (n_b > 10) {
    cal_data.neutral_b_w = sum_b_w / n_b;
    cal_data.neutral_b_x = sum_b_x / n_b;
    cal_data.neutral_b_y = sum_b_y / n_b;
    cal_data.neutral_b_z = sum_b_z / n_b;
    double mag = sqrt(cal_data.neutral_b_w*cal_data.neutral_b_w + cal_data.neutral_b_x*cal_data.neutral_b_x +
                      cal_data.neutral_b_y*cal_data.neutral_b_y + cal_data.neutral_b_z*cal_data.neutral_b_z);
    cal_data.neutral_b_w /= mag; cal_data.neutral_b_x /= mag;
    cal_data.neutral_b_y /= mag; cal_data.neutral_b_z /= mag;
    SERIAL_PORT.print(F("IMU_B: OK (")); SERIAL_PORT.print(n_b); SERIAL_PORT.println(F(" samples)"));
  } else { SERIAL_PORT.println(F("IMU_B: FAILED")); success = false; }
  
  if (success) {
    cal_data.calibrated = true;
    cal_data.calibration_time_ms = millis();
    saveCalibrationToNVS();
    drift.last_check_ms = millis();
    drift.was_stationary = false;
    drift.warning_count = 0;
    v_sh_r.reset(); v_sh_p.reset(); v_sh_y.reset();
    v_el_r.reset(); v_el_p.reset(); v_el_y.reset();
    v_wr_r.reset(); v_wr_p.reset(); v_wr_y.reset();
    resetPeaks();
    SERIAL_PORT.println(F("\nCALIBRATION: SUCCESS\n"));
  } else {
    SERIAL_PORT.println(F("\nCALIBRATION: FAILED\n"));
  }
  
  output_enabled = true;
}

// ============ SERIAL COMMANDS ============
void handleCommands() {
  if (!Serial.available()) return;
  
  char cmd = Serial.read();
  while (Serial.available()) Serial.read();
  
  switch (cmd) {
    case 'c': case 'C': calibrateZero(); break;
    case 'x': case 'X': clearCalibrationFromNVS(); break;
    case 'p': case 'P':
      output_enabled = !output_enabled;
      SERIAL_PORT.print(F("OUTPUT:")); SERIAL_PORT.println(output_enabled ? F("ON") : F("PAUSED"));
      break;
    case 's': case 'S':
      SERIAL_PORT.println(F("\n=== STATUS ==="));
      SERIAL_PORT.print(F("CALIBRATED: ")); SERIAL_PORT.println(cal_data.calibrated ? F("YES") : F("NO"));
      SERIAL_PORT.print(F("WIFI: ")); SERIAL_PORT.println(wifi_connected ? WiFi.localIP().toString() : F("DISCONNECTED"));
      SERIAL_PORT.print(F("HTTP OK/FAIL: ")); SERIAL_PORT.print(http_success_count);
      SERIAL_PORT.print(F("/")); SERIAL_PORT.println(http_fail_count);
      SERIAL_PORT.print(F("HTTP LATENCY: ")); SERIAL_PORT.print(http_last_duration_ms); SERIAL_PORT.println(F(" ms"));
      SERIAL_PORT.print(F("WRIST: ")); SERIAL_PORT.println(wrist_data.valid ? F("OK") : F("NO DATA"));
      SERIAL_PORT.println(F("==================\n"));
      break;
    case 'h': case 'H': case '?':
      SERIAL_PORT.println(F("\n=== COMMANDS ==="));
      SERIAL_PORT.println(F("c=calibrate x=clear p=pause s=status h=help"));
      SERIAL_PORT.println(F("================\n"));
      break;
  }
}

// ============ SETUP ============
void setup() {
  SERIAL_PORT.begin(115200);
  delay(500);
  
  SERIAL_PORT.println(F("\n================================================"));
  SERIAL_PORT.println(F("     VOMAS - ESP32-A MASTER v3.9                "));
  SERIAL_PORT.println(F("     REST API + Fast HTTP POST                  "));
  SERIAL_PORT.println(F("================================================\n"));

  // Create mutex
  dataMutex = xSemaphoreCreateMutex();

  // WiFi Setup
  WiFi.mode(WIFI_AP_STA);
  WiFi.begin(WIFI_SSID, WIFI_PASSWORD);
  
  SERIAL_PORT.print(F("Connecting to WiFi"));
  int attempts = 0;
  while (WiFi.status() != WL_CONNECTED && attempts < 20) {
    delay(500);
    SERIAL_PORT.print(".");
    attempts++;
  }
  
  if (WiFi.status() == WL_CONNECTED) {
    wifi_connected = true;
    SERIAL_PORT.println(F(" CONNECTED!"));
    SERIAL_PORT.print(F("IP: ")); SERIAL_PORT.println(WiFi.localIP());
    
    // Setup REST API endpoints
    server.on("/api/data", HTTP_GET, handleGetData);
    server.on("/api/data", HTTP_OPTIONS, handleOptions);
    // Calibration endpoints removed - ESP32 now polls NestJS backend
    server.onNotFound(handleNotFound);
    server.begin();
    
    SERIAL_PORT.println(F("\n========================================"));
    SERIAL_PORT.println(F("REST API ENDPOINTS:"));
    SERIAL_PORT.print(F("  GET http://")); SERIAL_PORT.print(WiFi.localIP()); SERIAL_PORT.println(F("/api/data"));
    SERIAL_PORT.print(F("  POLLING: ")); SERIAL_PORT.println(CALIBRATION_CHECK_URL);
    SERIAL_PORT.println(F("========================================"));
    SERIAL_PORT.print(F("POSTING TO: ")); SERIAL_PORT.println(SERVER_URL);
    SERIAL_PORT.println(F("========================================\n"));
    
    // Start HTTP POST task on Core 0
    xTaskCreatePinnedToCore(httpTask, "HTTP_Task", 8192, NULL, 1, &httpTaskHandle, 0);
    SERIAL_PORT.println(F("HTTP Task started on Core 0"));
  } else {
    wifi_connected = false;
    SERIAL_PORT.println(F(" FAILED - HTTP disabled"));
  }
  
  SERIAL_PORT.print(F("MAC: ")); SERIAL_PORT.println(WiFi.macAddress());

  // ESP-NOW
  if (esp_now_init() != ESP_OK) {
    SERIAL_PORT.println(F("ESP_NOW: FAILED"));
    while(1) delay(1000);
  }
  esp_now_register_recv_cb(onDataReceived);
  SERIAL_PORT.println(F("ESP_NOW: OK"));

  // I2C
  WIRE_PORT.begin(21, 22);
  WIRE_PORT.setClock(I2C_SPEED);

  // IMU-A
  SERIAL_PORT.print(F("IMU_A: "));
  imu_a.begin(WIRE_PORT, AD0_IMU_A);
  int retries = 0;
  while (imu_a.status != ICM_20948_Stat_Ok && retries < 10) {
    delay(500); imu_a.begin(WIRE_PORT, AD0_IMU_A); retries++;
  }
  if (imu_a.status == ICM_20948_Stat_Ok) {
    imu_a.initializeDMP();
    imu_a.enableDMPSensor(INV_ICM20948_SENSOR_GAME_ROTATION_VECTOR);
    imu_a.setDMPODRrate(DMP_ODR_Reg_Quat6, 0);
    imu_a.enableFIFO(); imu_a.enableDMP(); imu_a.resetDMP(); imu_a.resetFIFO();
    SERIAL_PORT.println(F("OK"));
  } else { SERIAL_PORT.println(F("FAILED")); }

  // IMU-B
  SERIAL_PORT.print(F("IMU_B: "));
  imu_b.begin(WIRE_PORT, AD0_IMU_B);
  retries = 0;
  while (imu_b.status != ICM_20948_Stat_Ok && retries < 10) {
    delay(500); imu_b.begin(WIRE_PORT, AD0_IMU_B); retries++;
  }
  if (imu_b.status == ICM_20948_Stat_Ok) {
    imu_b.initializeDMP();
    imu_b.enableDMPSensor(INV_ICM20948_SENSOR_GAME_ROTATION_VECTOR);
    imu_b.setDMPODRrate(DMP_ODR_Reg_Quat6, 0);
    imu_b.enableFIFO(); imu_b.enableDMP(); imu_b.resetDMP(); imu_b.resetFIFO();
    SERIAL_PORT.println(F("OK"));
  } else { SERIAL_PORT.println(F("FAILED")); }

  // Init trackers
  v_sh_r.init(); v_sh_p.init(); v_sh_y.init();
  v_el_r.init(); v_el_p.init(); v_el_y.init();
  v_wr_r.init(); v_wr_p.init(); v_wr_y.init();
  
  drift.last_check_ms = millis();
  drift.warning_count = 0;
  peak_window_start = millis();

  // Load calibration
  SERIAL_PORT.print(F("Loading calibration... "));
  if (loadCalibrationFromNVS()) {
    SERIAL_PORT.println(F("OK"));
  } else {
    SERIAL_PORT.println(F("NOT FOUND - Press 'c' or call /api/calibrate"));
  }

  SERIAL_PORT.println(F("\n================================================"));
  SERIAL_PORT.println(F("COMMANDS: c=calibrate p=pause s=status h=help"));
  SERIAL_PORT.println(F("================================================\n"));
}

// ============ MAIN LOOP (RUNS ON CORE 1) ============
void loop() {
  handleCommands();
  
  // Handle HTTP server requests
  if (wifi_connected) {
    server.handleClient();
  }
  
  // Check for calibration request from API
  if (calibrationRequested) {
    calibrationRequested = false;
    calibrateZero();
  }
  
  sendTimeSync();
  checkWristConnection();
  
  // Read IMUs
  drainFIFO(imu_a);
  drainFIFO(imu_b);
  
  icm_20948_DMP_data_t da, db;
  imu_a.readDMPdataFromFIFO(&da);
  imu_b.readDMPdataFromFIFO(&db);
  
  double qw, qx, qy, qz;
  
  if (buildQuatFromDMP(da, qw, qx, qy, qz)) {
    imu_data[0].w = qw; imu_data[0].x = qx;
    imu_data[0].y = qy; imu_data[0].z = qz;
    imu_data[0].valid = true;
  }
  
  if (buildQuatFromDMP(db, qw, qx, qy, qz)) {
    imu_data[1].w = qw; imu_data[1].x = qx;
    imu_data[1].y = qy; imu_data[1].z = qz;
    imu_data[1].valid = true;
  }
  
  if (!cal_data.calibrated) {
    static unsigned long last_reminder = 0;
    if (millis() - last_reminder > 5000) {
      SERIAL_PORT.println(F("NOT_CALIBRATED - Press 'c' or call /api/calibrate"));
      last_reminder = millis();
    }
    delay(100);
    return;
  }
  
  // Calculate angles
  getShoulderAngles(sh_roll, sh_pitch, sh_yaw);
  getElbowAngles(el_roll, el_pitch, el_yaw);
  getWristAngles(wr_roll, wr_pitch, wr_yaw);
  
  // Update velocities
  v_sh_r.update(sh_roll); v_sh_p.update(sh_pitch); v_sh_y.update(sh_yaw);
  v_el_r.update(el_roll); v_el_p.update(el_pitch); v_el_y.update(el_yaw);
  v_wr_r.update(wr_roll); v_wr_p.update(wr_pitch); v_wr_y.update(wr_yaw);
  
  checkDrift();
  updatePeaks();
  
  // Update shared data for HTTP POST task
  updateSharedData();
  
  // Serial output
  if (output_enabled) {
    SERIAL_PORT.print(F("SH:")); SERIAL_PORT.print((int)sh_roll);
    SERIAL_PORT.print(F(",")); SERIAL_PORT.print((int)sh_pitch);
    SERIAL_PORT.print(F(",")); SERIAL_PORT.print((int)sh_yaw);
    SERIAL_PORT.print(F(" EL:")); SERIAL_PORT.print((int)el_roll);
    SERIAL_PORT.print(F(",")); SERIAL_PORT.print((int)el_pitch);
    SERIAL_PORT.print(F(",")); SERIAL_PORT.print((int)el_yaw);
    SERIAL_PORT.print(F(" WR:")); SERIAL_PORT.print((int)wr_roll);
    SERIAL_PORT.print(F(",")); SERIAL_PORT.print((int)wr_pitch);
    SERIAL_PORT.print(F(",")); SERIAL_PORT.print((int)wr_yaw);
    SERIAL_PORT.print(F(" HTTP:")); SERIAL_PORT.print(http_last_duration_ms);
    SERIAL_PORT.println(F("ms"));
    
    if (millis() - peak_window_start >= PEAK_HOLD_MS) {
      resetPeaks();
    }
  }
  
  delay(20);
}