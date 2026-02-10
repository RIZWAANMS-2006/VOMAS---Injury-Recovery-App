# Testing Guide for VOMAS

This guide covers how to test both the **backend (NestJS)** and **frontend (Flutter)** components of the VOMASlication.

---

## Prerequisites

Before testing, ensure you have:

- Node.js 18+ installed
- Flutter 3.x installed
- Postman (optional, for API testing)

---

## 1. Backend Testing

### 1.1 Start the Backend Server

```bash
cd VOMAS-backend
npm install
npm run start:dev
```

Server runs at: `https://vomas-injury-recovery-app.onrender.com`

---

### 1.2 Run Unit Tests

```bash
cd VOMAS-backend
npm test
```

**Expected Output:**

```
PASS  src/app.controller.spec.ts
PASS  src/activities/activities.controller.spec.ts

Test Suites: 2 passed, 2 total
Tests:       9 passed, 9 total
```

---

### 1.3 API Endpoint Tests (Postman / curl)

#### Test 1: Get Action Mappings

| Field  | Value                                                        |
| ------ | ------------------------------------------------------------ |
| Method | GET                                                          |
| URL    | `https://vomas-injury-recovery-app.onrender.com/api/actions` |

**Expected Response:**

```json
{
  "success": true,
  "data": {
    "Flexion / Extension": {
      "shoulder": "Roll",
      "elbow": "Roll",
      "wrist": "Pitch"
    },
    ...
  }
}
```

---

#### Test 2: Create Activity (Valid Action)

| Field   | Value                                                           |
| ------- | --------------------------------------------------------------- |
| Method  | POST                                                            |
| URL     | `https://vomas-injury-recovery-app.onrender.com/api/activities` |
| Headers | `Content-Type: application/json`                                |
| Body    | `{ "actionName": "Flexion / Extension" }`                       |

**Expected Response:**

```json
{
  "success": true,
  "data": {
    "id": "1770058659000-abc123",
    "actionName": "Flexion / Extension",
    "measurements": {
      "shoulder": "Roll",
      "elbow": "Roll",
      "wrist": "Pitch"
    },
    "timestamp": "2026-02-02T13:47:39.000Z"
  }
}
```

---

#### Test 3: Create Activity (Invalid Action)

| Field  | Value                                                           |
| ------ | --------------------------------------------------------------- |
| Method | POST                                                            |
| URL    | `https://vomas-injury-recovery-app.onrender.com/api/activities` |
| Body   | `{ "actionName": "Invalid Action" }`                            |

**Expected Response:**

```json
{
  "success": false,
  "error": {
    "code": "INVALID_ACTION",
    "message": "Unsupported action name: \"Invalid Action\""
  }
}
```

---

#### Test 4: Get Activity History

| Field  | Value                                                           |
| ------ | --------------------------------------------------------------- |
| Method | GET                                                             |
| URL    | `https://vomas-injury-recovery-app.onrender.com/api/activities` |

**Expected Response:**

```json
{
  "success": true,
  "data": [
    {
      "id": "...",
      "actionName": "Flexion / Extension",
      "measurements": { ... },
      "timestamp": "..."
    }
  ]
}
```

---

#### Test 5: Send Angle Data (WebSocket Trigger)

| Field  | Value                                                         |
| ------ | ------------------------------------------------------------- |
| Method | POST                                                          |
| URL    | `https://vomas-injury-recovery-app.onrender.com/VOMAS/angles` |
| Body   | `{ "shoulder": 45.5, "elbow": 30.0, "wrist": 15.2 }`          |

**Expected Response:**

```json
{
  "status": "received",
  "data": {
    "shoulder": 45.5,
    "elbow": 30.0,
    "wrist": 15.2
  }
}
```

---

### 1.4 Valid Action Names for Testing

Use any of these exact action names in your POST requests:

| Action Name                        |
| ---------------------------------- |
| `Flexion / Extension`              |
| `Horizontal Abduction / Adduction` |
| `Internal / External Rotation`     |
| `Scapular Plane Elevation`         |
| `Reaching Forward`                 |
| `Reaching to the Side`             |
| `Reaching to the Mouth`            |
| `Reaching Behind Back`             |
| `Combined Movement`                |

---

## 2. Frontend Testing

### 2.1 Start the Frontend

```bash
cd VOMAS-frontend
flutter pub get
flutter run -d windows
```

---

### 2.2 Run Flutter Tests

```bash
cd VOMAS-frontend
flutter test
```

---

### 2.3 Manual UI Testing Checklist

#### Home Screen Tests

| #   | Test Case           | Steps                               | Expected Result                                      |
| --- | ------------------- | ----------------------------------- | ---------------------------------------------------- |
| 1   | App loads           | Launch app                          | Home screen displays with action grid                |
| 2   | Actions display     | View home screen                    | All 9 action cards visible                           |
| 3   | Select action       | Tap any action card                 | Navigates to measurement screen and saves to history |
| 4   | History displays    | Return to home screen               | Activity appears in history section                  |
| 5   | Delete history item | Swipe/tap delete on history item    | Item removed from list                               |
| 6   | Clear all history   | Tap delete icon in app bar, confirm | All history cleared                                  |

---

#### Measurement Screen Tests

| #   | Test Case         | Steps                        | Expected Result                       |
| --- | ----------------- | ---------------------------- | ------------------------------------- |
| 1   | Screen loads      | Select any action            | Measurement screen displays           |
| 2   | Connect to server | Tap "Connect" button         | Status changes to "Connected" (green) |
| 3   | Receive angles    | Send POST to `/VOMAS/angles` | Angles display on screen in real-time |
| 4   | Disconnect        | Tap "Disconnect"             | Status changes to "Disconnected"      |
| 5   | Connection error  | Stop backend, try connect    | Shows error state                     |

---

### 2.4 Integration Test: Full Flow

1. **Start backend:** `npm run start:dev`
2. **Start frontend:** `flutter run -d windows`
3. **Select action:** Tap "Flexion / Extension"
4. **Connect:** Tap connect button on measurement screen
5. **Send angles via Postman:**
   ```json
   POST https://vomas-injury-recovery-app.onrender.com/VOMAS/angles
   { "shoulder": 90.0, "elbow": 45.0, "wrist": 30.0 }
   ```
6. **Verify:** Angles appear on Flutter app in real-time
7. **Go back:** Press back button
8. **Verify history:** Activity appears in home screen history

---

## 3. Offline/Fallback Testing

### Test Backend Unavailable Scenario

1. **Stop the backend server**
2. **Launch Flutter app**
3. **Select an action**
4. **Expected:** App works using local storage (no crash)
5. **Verify:** Activity saved to local history

### Test Backend Recovery

1. **Start with backend stopped**
2. **Create some activities (saved locally)**
3. **Start backend server**
4. **Restart Flutter app**
5. **Expected:** App syncs with backend

---

## 4. Quick Test Commands

### PowerShell Commands for API Testing

```powershell
# Get action mappings
Invoke-RestMethod -Uri "https://vomas-injury-recovery-app.onrender.com/api/actions" -Method Get

# Create activity
$body = @{actionName='Flexion / Extension'} | ConvertTo-Json
Invoke-RestMethod -Uri "https://vomas-injury-recovery-app.onrender.com/api/activities" -Method Post -Body $body -ContentType "application/json"

# Get history
Invoke-RestMethod -Uri "https://vomas-injury-recovery-app.onrender.com/api/activities" -Method Get

# Send angles
$angles = @{shoulder=45.5; elbow=30.0; wrist=15.2} | ConvertTo-Json
Invoke-RestMethod -Uri "https://vomas-injury-recovery-app.onrender.com/VOMAS/angles" -Method Post -Body $angles -ContentType "application/json"
```

---

## 5. Troubleshooting

| Issue                           | Solution                                            |
| ------------------------------- | --------------------------------------------------- |
| Backend not starting            | Run `npm install` first                             |
| "Connection timeout" in Flutter | Check backend is running on port 3000               |
| CORS errors                     | Backend has CORS enabled; restart if issues persist |
| Angles not updating             | Verify WebSocket connection status is "Connected"   |
| History not showing             | Check SharedPreferences or restart app              |
