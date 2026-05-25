/**
 * AssureManager REST API Server
 * Express + mssql with mock data fallback
 */
const express = require('express');
const cors = require('cors');
require('dotenv').config();

const app = express();

// Middleware
app.use(cors({
  origin: process.env.CORS_ORIGIN || '*',
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'PATCH', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization'],
}));
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Request logging middleware
app.use((req, res, next) => {
  console.log(`${new Date().toISOString()} [${req.method}] ${req.path}`);
  next();
});

// Routes
app.use('/api/v1', require('./routes'));

// Root endpoint
app.get('/', (req, res) => {
  res.json({
    name: 'AssureManager API',
    version: '1.0.0',
    description: 'Belgian Insurance Management System REST API',
    endpoints: {
      dashboard: '/api/v1/dashboard/stats, /charts, /activities, /alerts',
      personen: '/api/v1/personen',
      instellingen: '/api/v1/instellingen',
      objecten: '/api/v1/objecten',
      contracten: '/api/v1/contracten',
      schadeclaims: '/api/v1/schadeclaims',
      rapporten: '/api/v1/rapporten/commissions, /contracts, /claims, /clients',
      beheer: '/api/v1/beheer/users, /auditlog, /settings',
      health: '/api/v1/health',
    },
  });
});

// 404 handler
app.use((req, res) => {
  res.status(404).json({ error: 'Endpoint not found', path: req.path });
});

// Global error handler
app.use((err, req, res, next) => {
  console.error('Unhandled error:', err);
  res.status(500).json({
    error: 'Internal server error',
    message: process.env.NODE_ENV === 'development' ? err.message : 'Something went wrong',
  });
});

const PORT = process.env.PORT || 3001;
app.listen(PORT, () => {
  console.log('========================================');
  console.log('  AssureManager API');
  console.log('  Version: 1.0.0');
  console.log(`  Port: ${PORT}`);
  console.log(`  Base URL: http://localhost:${PORT}/api/v1`);
  console.log('========================================');
});

module.exports = app;
