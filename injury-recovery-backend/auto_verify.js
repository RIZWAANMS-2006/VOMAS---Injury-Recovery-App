const http = require('http');

const data = JSON.stringify({
    "shoulder": {
        "roll": { "angle": 10.0, "speed": 1.0 },
        "pitch": { "angle": 20.0, "speed": 1.0 },
        "yaw": { "angle": 5.0, "speed": 1.0 }
    },
    "elbow": {
        "roll": { "angle": 45.0, "speed": 2.0 },
        "pitch": { "angle": 30.0, "speed": 2.0 },
        "yaw": { "angle": 10.0, "speed": 2.0 }
    },
    "wrist": {
        "roll": { "angle": 15.0, "speed": 1.5 },
        "pitch": { "angle": 25.0, "speed": 1.5 },
        "yaw": { "angle": 5.0, "speed": 1.5 }
    }
});

const options = {
    hostname: 'localhost',
    port: 3000,
    path: '/VOMAS/angles',
    method: 'POST',
    headers: {
        'Content-Type': 'application/json',
        'Content-Length': data.length
    }
};

console.log('--- Sending Verification Request ---');
const req = http.request(options, (res) => {
    console.log(`STATUS: ${res.statusCode}`);
    res.setEncoding('utf8');
    res.on('data', (chunk) => {
        console.log(`RESPONSE: ${chunk}`);
    });
});

req.on('error', (e) => {
    console.error(`ERROR: ${e.message}`);
});

req.write(data);
req.end();
