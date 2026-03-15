
// IoT Simulator for VOMAS
// Run with: npx ts-node --moduleResolution node scripts/simulate_iot.ts

const API_URL = 'https://mrtzzhhh-3000.inc1.devtunnels.ms';

interface MeasurementData {
  angle: number;
  speed?: number;
}

interface JointData {
  roll: MeasurementData;
  pitch: MeasurementData;
  yaw: MeasurementData;
}

interface AnglesDto {
  shoulder: JointData;
  elbow: JointData;
  wrist: JointData;
}

const ZERO_POSE: AnglesDto = {
  shoulder: {
     roll: { angle: (Math.random() - 0.5) * 180, speed: (Math.random() - 0.5) * 20 },
    pitch: { angle: (Math.random() - 0.5) * 90, speed: (Math.random() - 0.5) * 10 },
    yaw: { angle: (Math.random() - 0.5) * 60, speed: (Math.random() - 0.5) * 4 },
  },
  elbow: {
   roll: { angle: (Math.random() - 0.5) * 180, speed: (Math.random() - 0.5) * 20 },
    pitch: { angle: (Math.random() - 0.5) * 90, speed: (Math.random() - 0.5) * 10 },
    yaw: { angle: (Math.random() - 0.5) * 60, speed: (Math.random() - 0.5) * 4 },
  },
  wrist: {
   roll: { angle: (Math.random() - 0.5) * 180, speed: (Math.random() - 0.5) * 20 },
    pitch: { angle: (Math.random() - 0.5) * 90, speed: (Math.random() - 0.5) * 10 },
    yaw: { angle: (Math.random() - 0.5) * 60, speed: (Math.random() - 0.5) * 4 },
  },
};

let zeroModeUntil: number = 0; // Timestamp until which we send ZERO_POSE

// Helper to generate a dummy joint data
function createdummyJoint(t: number, phase: number): JointData {
  return {
    roll: { angle: Math.sin(t / 1000 + phase) * 90, speed: Math.cos(t / 1000 + phase) * 10 },
    pitch: { angle: Math.cos(t / 1200 + phase) * 45, speed: -Math.sin(t / 1200 + phase) * 5 },
    yaw: { angle: Math.sin(t / 1500 + phase) * 30, speed: Math.cos(t / 1500 + phase) * 2 },
  };
}

// Function to send angle data
async function sendAngles() {
  const t = Date.now();
  let angles: AnglesDto;

  if (Date.now() < zeroModeUntil) {
    angles = ZERO_POSE; // Send Zero Pose
  } else {
    // Send Wave Data
    angles = {
      shoulder: createdummyJoint(t, 0),
      elbow: createdummyJoint(t, 1),
      wrist: createdummyJoint(t, 2),
    };
  }

  try {
    const response = await fetch(`${API_URL}/VOMAS/angles`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(angles),
    });

    if (response.ok) {
       if (Date.now() < zeroModeUntil) {
           process.stdout.write('Z'); // 'Z' for Zero
       } else {
           process.stdout.write('.'); // '.' for Normal
       }
    } else {
      console.error(`\n[${new Date().toISOString()}] Failed to send angles: ${response.status} ${response.statusText} ${response.body}`);
    }
  } catch (error) {
    console.error(`\n[${new Date().toISOString()}] Error sending angles:`, error instanceof Error ? error.message : error);
  }
}

// Function to check calibration
async function checkCalibration() {
  try {
    const response = await fetch(`${API_URL}/VOMAS/calibration-check`);
    if (response.ok) {
        const data = await response.json();
        if (data && data.calibrate === 'true') {
            console.log(`\n[${new Date().toISOString()}] !!! CALIBRATION REQUEST RECEIVED !!!`);
            console.log(`[${new Date().toISOString()}] Resetting to ZERO POSE for 5 seconds...`);
            zeroModeUntil = Date.now() + 5000;
        }
    } else {
        console.error(`\n[${new Date().toISOString()}] Failed to check calibration: ${response.status}`);
    }
  } catch (error) {
    console.error(`\n[${new Date().toISOString()}] Error checking calibration:`, error instanceof Error ? error.message : error);
  }
}

console.log('Starting VOMAS IoT Simulator...');
console.log(`Target API: ${API_URL}`);
console.log('Sending angles every 100ms...');
console.log('Checking calibration every 2000ms...');

// Send angles every 100ms (10Hz)
setInterval(sendAngles, 1500);

// Check calibration every 2 seconds
setInterval(checkCalibration, 1000);
