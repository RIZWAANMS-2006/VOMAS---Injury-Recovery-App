# VOMAS Backend

## Quick Start

```bash
# Install dependencies
npm install

# Run Development (with hot reload)
npm run start:dev

# Production build
npm run build
npm run start:prod

# Run tests
npm test

# Server runs on: https://vomas-injury-recovery-app.onrender.com
```

## API Endpoints

### Activities API

| Method | Endpoint          | Description                      | Request Body        | Response                                    |
| ------ | ----------------- | -------------------------------- | ------------------- | ------------------------------------------- |
| POST   | /api/activities   | Create activity from action name | CreateActivityDto   | `{ success: true, data: ActivityRecord }`  |
| GET    | /api/activities   | Get all activity history         | -                   | `{ success: true, data: ActivityRecord[] }`|
| GET    | /api/actions      | Get action → measurement mapping | -                   | `{ success: true, data: MappingObject }`   |

### Angle Streaming API

| Method | Endpoint                | Description                | Request Body | Response                             |
| ------ | ----------------------- | -------------------------- | ------------ | ------------------------------------ |
| POST   | /VOMAS/angles | Receive & broadcast angles | AnglesDto    | `{ status: 'received', data: angles }` |

### WebSocket Events

| Direction       | Event         | Payload   | Description                                         |
| --------------- | ------------- | --------- | --------------------------------------------------- |
| Server → Client | angles-update | AnglesDto | Broadcasts received angles to ALL connected clients |

---

## Data Models

### ActivityRecord

```json
{
  "id": "1706803200000-abc123",
  "actionName": "Flexion / Extension",
  "measurements": {
    "shoulder": "Roll",
    "elbow": "Roll",
    "wrist": "Pitch"
  },
  "timestamp": "2026-02-01T14:30:00.000Z"
}
```

### CreateActivityDto

```json
{
  "actionName": "Flexion / Extension"
}
```

### AnglesDto

```json
{
  "shoulder": 65.2,
  "elbow": 32.1,
  "wrist": 12.4
}
```

---

## Action → Measurement Mapping

The following actions are supported:

| Action Name                        | Shoulder | Elbow | Wrist |
| ---------------------------------- | -------- | ----- | ----- |
| Flexion / Extension                | Roll     | Roll  | Pitch |
| Abduction                          | Roll     | Roll  | Pitch |
| Internal / External Rotation       | Pitch    | Roll  | Pitch |
| Horizontal Abduction / Adduction   | Yaw      | Roll  | Pitch |
| Forearm Pronation / Supination     | Roll     | Roll  | Roll  |
| Radial / Ulnar Deviation           | Roll     | Roll  | Yaw   |

---

## Example API Calls

### Create Activity

```bash
curl -X POST https://vomas-injury-recovery-app.onrender.com/api/activities \
  -H "Content-Type: application/json" \
  -d '{"actionName": "Flexion / Extension"}'
```

**Response (201 Created):**
```json
{
  "success": true,
  "data": {
    "id": "1706803200000-abc123",
    "actionName": "Flexion / Extension",
    "measurements": {
      "shoulder": "Roll",
      "elbow": "Roll",
      "wrist": "Pitch"
    },
    "timestamp": "2026-02-01T14:30:00.000Z"
  }
}
```

### Create Activity (Invalid Action)

```bash
curl -X POST https://vomas-injury-recovery-app.onrender.com/api/activities \
  -H "Content-Type: application/json" \
  -d '{"actionName": "Invalid Action"}'
```

**Response (201 with success=false):**
```json
{
  "success": false,
  "error": {
    "code": "INVALID_ACTION",
    "message": "Unsupported action name: \"Invalid Action\""
  }
}
```

### Get Activities

```bash
curl https://vomas-injury-recovery-app.onrender.com/api/activities
```

**Response:**
```json
{
  "success": true,
  "data": [
    {
      "id": "1706803200000-abc123",
      "actionName": "Flexion / Extension",
      "measurements": { "shoulder": "Roll", "elbow": "Roll", "wrist": "Pitch" },
      "timestamp": "2026-02-01T14:30:00.000Z"
    }
  ]
}
```

### Get Action Mappings

```bash
curl https://vomas-injury-recovery-app.onrender.com/api/actions
```

**Response:**
```json
{
  "success": true,
  "data": {
    "Flexion / Extension": { "shoulder": "Roll", "elbow": "Roll", "wrist": "Pitch" },
    "Abduction": { "shoulder": "Roll", "elbow": "Roll", "wrist": "Pitch" },
    "Internal / External Rotation": { "shoulder": "Pitch", "elbow": "Roll", "wrist": "Pitch" },
    "Horizontal Abduction / Adduction": { "shoulder": "Yaw", "elbow": "Roll", "wrist": "Pitch" },
    "Forearm Pronation / Supination": { "shoulder": "Roll", "elbow": "Roll", "wrist": "Roll" },
    "Radial / Ulnar Deviation": { "shoulder": "Roll", "elbow": "Roll", "wrist": "Yaw" }
  }
}
```

### Post Angles

```bash
curl -X POST https://vomas-injury-recovery-app.onrender.com/VOMAS/angles \
  -H "Content-Type: application/json" \
  -d '{"shoulder": 65.2, "elbow": 32.1, "wrist": 12.4}'
```

---

## Error Codes

| Code            | Description                           |
| --------------- | ------------------------------------- |
| INVALID_ACTION  | The provided action name is not valid |
| VALIDATION_ERROR| Request body validation failed        |
| NOT_FOUND       | Requested resource not found          |
| INTERNAL_ERROR  | Internal server error                 |

---

## Dependencies

```bash
npm install @nestjs/common @nestjs/core @nestjs/platform-express
npm install @nestjs/websockets @nestjs/platform-socket.io
npm install class-validator class-transformer
npm install socket.io
npm install --save-dev @types/socket.io
```