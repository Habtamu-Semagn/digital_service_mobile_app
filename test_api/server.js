const express = require('express');
const cors = require('cors');
const app = express();
const port = 3000;

app.use(cors());
app.use(express.json());

// Logging middleware
app.use((req, res, next) => {
  console.log(`[${new Date().toISOString()}] ${req.method} ${req.url}`);
  if (Object.keys(req.body).length > 0) {
    console.log('Body:', JSON.stringify(req.body, null, 2));
  }
  next();
});

// Auth Login Mock
app.post('/v1/auth/login', (req, res) => {
  const { email, password } = req.body;

  // Simple mock response
  res.json({
    success: true,
    data: {
      token: "mock_access_token_jwt",
      refreshToken: "mock_refresh_token_jwt",
      user: {
        id: "user_123",
        email: email || "test@example.com",
        fullName: "Test User",
        fullNameAm: "ሙከራ ተጠቃሚ",
        role: "CITIZEN",
        phoneNumber: "+251911223344",
        preferredLanguage: "en",
        createdAt: new Date().toISOString()
      }
    }
  });
});

// Auth Refresh Mock
app.post('/v1/auth/refresh', (req, res) => {
  res.json({
    success: true,
    data: {
      token: "new_mock_access_token_jwt",
      refreshToken: "new_mock_refresh_token_jwt"
    }
  });
});

// Auth Logout Mock
app.post('/v1/auth/logout', (req, res) => {
  res.json({ success: true });
});

app.listen(port, () => {
  console.log(`Mock API listening at http://localhost:${port}`);
});
