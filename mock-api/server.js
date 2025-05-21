const express = require('express');
const app = express();
const port = 8080;

app.use(express.json());

// Endpoint that requires authentication (will be protected by APISIX)
app.get('/api/secure', (req, res) => {
  res.json({
    message: 'This is a secure API endpoint',
    receivedHeaders: req.headers
  });
});

// Public endpoint (no auth required in APISIX config)
app.get('/public/info', (req, res) => {
  res.json({
    message: 'This is a public API endpoint',
    time: new Date().toISOString()
  });
});

app.listen(port, () => {
  console.log(`Mock API running on port ${port}`);
});