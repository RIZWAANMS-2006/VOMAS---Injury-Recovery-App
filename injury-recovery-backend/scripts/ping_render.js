const API_URL = 'https://vomas-injury-recovery-app.onrender.com/VOMAS/calibration-check';
const INTERVAL_MS = 15 * 60 * 1000;

async function ping() {
  const start = Date.now();
  try {
    const res = await fetch(API_URL, { method: 'GET' });
    const ms = Date.now() - start;
    if (!res.ok) {
      console.error(`[${new Date().toISOString()}] ${res.status} ${res.statusText} (${ms}ms)`);
      return;
    }
    console.log(`[${new Date().toISOString()}] OK (${ms}ms)`);
  } catch (err) {
    console.error(`[${new Date().toISOString()}] ERROR`, err);
  }
}

console.log('Starting Render ping every 15 minutes...');
console.log(`Target: ${API_URL}`);

ping();
setInterval(ping, INTERVAL_MS);
