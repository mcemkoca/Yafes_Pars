/**
 * Beheer (Admin) Routes
 * GET /api/v1/beheer/users
 * GET /api/v1/beheer/auditlog
 * GET /api/v1/beheer/settings
 * PUT /api/v1/beheer/settings
 */
const express = require('express');
const router = express.Router();
const { pool, sql, checkConnection } = require('../db');
const mockData = require('../mockData');

// GET /beheer/users - User list
router.get('/users', async (req, res) => {
  try {
    const dbAvailable = await checkConnection();
    const page = parseInt(req.query.page) || 1;
    const limit = parseInt(req.query.limit) || 20;

    if (dbAvailable) {
      try {
        const result = await pool.request()
          .input('Page', sql.Int, page)
          .input('Limit', sql.Int, limit)
          .execute('sp_Beheer_GetUsers');
        res.json({
          data: result.recordset,
          pagination: { page, limit, total: result.recordset.length }
        });
        return;
      } catch (spErr) {
        console.warn('Stored procedure failed, falling back to mock data:', spErr.message);
      }
    }

    res.json(mockData.paginate(mockData.users, page, limit));
  } catch (err) {
    console.error('Error fetching users:', err);
    res.status(500).json({ error: 'Internal server error', message: err.message });
  }
});

// GET /beheer/auditlog - Audit log entries
router.get('/auditlog', async (req, res) => {
  try {
    const dbAvailable = await checkConnection();
    const page = parseInt(req.query.page) || 1;
    const limit = parseInt(req.query.limit) || 20;
    const gebruiker = req.query.gebruiker || '';
    const actie = req.query.actie || '';

    if (dbAvailable) {
      try {
        const result = await pool.request()
          .input('Page', sql.Int, page)
          .input('Limit', sql.Int, limit)
          .input('Gebruiker', sql.NVarChar(200), gebruiker)
          .input('Actie', sql.NVarChar(50), actie)
          .execute('sp_Beheer_GetAuditLog');
        res.json({
          data: result.recordset,
          pagination: { page, limit, total: result.recordset.length }
        });
        return;
      } catch (spErr) {
        console.warn('Stored procedure failed, falling back to mock data:', spErr.message);
      }
    }

    let filtered = [...mockData.auditLog];
    if (gebruiker) {
      filtered = filtered.filter(a => a.gebruiker.toLowerCase().includes(gebruiker.toLowerCase()));
    }
    if (actie) {
      filtered = filtered.filter(a => a.actie === actie.toUpperCase());
    }
    res.json(mockData.paginate(filtered, page, limit));
  } catch (err) {
    console.error('Error fetching audit log:', err);
    res.status(500).json({ error: 'Internal server error', message: err.message });
  }
});

// GET /beheer/settings - System settings
router.get('/settings', async (req, res) => {
  try {
    const dbAvailable = await checkConnection();

    if (dbAvailable) {
      try {
        const result = await pool.request()
          .execute('sp_Beheer_GetSettings');
        res.json(result.recordset[0] || mockData.settings);
        return;
      } catch (spErr) {
        console.warn('Stored procedure failed, falling back to mock data:', spErr.message);
      }
    }

    res.json(mockData.settings);
  } catch (err) {
    console.error('Error fetching settings:', err);
    res.status(500).json({ error: 'Internal server error', message: err.message });
  }
});

// PUT /beheer/settings - Update system settings
router.put('/settings', async (req, res) => {
  try {
    const dbAvailable = await checkConnection();
    const data = req.body;

    if (dbAvailable) {
      try {
        await pool.request()
          .input('Settings', sql.NVarChar(sql.MAX), JSON.stringify(data))
          .execute('sp_Beheer_UpdateSettings');
        res.json({ message: 'Settings updated successfully' });
        return;
      } catch (spErr) {
        console.warn('Stored procedure failed, using mock:', spErr.message);
      }
    }

    // Update mock settings
    Object.assign(mockData.settings, data);
    res.json({ message: 'Settings updated successfully', data: mockData.settings });
  } catch (err) {
    console.error('Error updating settings:', err);
    res.status(500).json({ error: 'Internal server error', message: err.message });
  }
});

module.exports = router;
