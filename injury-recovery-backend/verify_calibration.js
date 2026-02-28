const axios = require('axios');

async function testCalibration() {
  const baseUrl = 'https://vomas-injury-recovery-app.onrender.com/VOMAS';

  try {
    console.log('1. Checking initial status (should be "none")...');
    let res = await axios.get(`${baseUrl}/calibration-check`);
    console.log('Initial Status:', res.data);

    // Simulate Client Triggering functionality is hard without WebSocket client here.
    // User should click the button in the App.
    console.log('\nPlease click "Calibrate" in the App now.');
    console.log('Waiting 10 seconds...');
    
    await new Promise(r => setTimeout(r, 10000));

    // Poll again
    console.log('\n2. Checking status after trigger (should be "true" if clicked)...');
    res = await axios.get(`${baseUrl}/calibration-check`);
    console.log('Status:', res.data);

    console.log('\n3. Checking status again (should be "none" - reset)...');
    res = await axios.get(`${baseUrl}/calibration-check`);
    console.log('Status:', res.data);

  } catch (error) {
    console.error('Error:', error.message);
  }
}

testCalibration();
