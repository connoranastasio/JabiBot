const express = require('express');
const bodyParser = require('body-parser');
const fs = require('fs');
const path = require('path');
const os = require('os');

const app = express();
const PORT = 3000;

// Serve static frontend files
app.use(express.static(path.join(__dirname, 'public')));
app.use(bodyParser.json());

// Utility: get local IP for displaying access URL
function getLocalIP() {
  const interfaces = os.networkInterfaces();
  for (const name of Object.keys(interfaces)) {
    for (const iface of interfaces[name]) {
      if (iface.family === 'IPv4' && !iface.internal) {
        return iface.address;
      }
    }
  }
  return 'localhost';
}

// GET /get-ip — used by frontend to display IP
app.get('/get-ip', (req, res) => {
  res.json({ ip: getLocalIP() });
});

// POST /save — write .env file
app.post('/save', (req, res) => {
  const envData = {
    ...req.body,
    DATA_DIR: './data', // Always hardcoded
  };

  // Warn about quotes in input values
  Object.entries(envData).forEach(([key, value]) => {
    if (value.includes('"')) {
      console.warn(`Warning: ${key} contains a quote. This may break parsing.`);
    }
  });

  const envLines = Object.entries(envData)
    .map(([key, value]) => `${key}=${value.trim()}`)
    .join('\n');

  const envPath = path.resolve(__dirname, '../.env');

  try {
    fs.writeFileSync(envPath, envLines + '\n');
    console.log('.env file saved successfully.');
    res.send('.env saved successfully.');
  } catch (err) {
    console.error('Error writing .env file:', err);
    res.status(500).send('Failed to save .env.');
  }
});

// Start server and print access info
app.listen(PORT, () => {
  const ip = getLocalIP();
  console.log('JabiBot Web Installer is running.');
  console.log(`Open your browser and go to: http://${ip}:${PORT}`);
});
