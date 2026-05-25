/**
 * Dashboard Routes
 * GET /api/v1/dashboard/stats
 * GET /api/v1/dashboard/charts
 * GET /api/v1/dashboard/activities
 * GET /api/v1/dashboard/alerts
 */
const express = require('express');
const router = express.Router();
const { pool, sql, checkConnection } = require('../db');
const mockData = require('../mockData');

// GET /dashboard/stats - KPI statistics
router.get('/stats', async (req, res) => {
  try {
    const dbAvailable = await checkConnection();
    if (dbAvailable) {
      // Placeholder for stored procedure call
      // const result = await pool.request().execute('sp_Dashboard_GetStats');
      // res.json(result.recordset[0]);
      res.json(mockData.kpiData);
    } else {
      res.json(mockData.kpiData);
    }
  } catch (err) {
    console.error('Error fetching dashboard stats:', err);
    res.status(500).json({ error: 'Internal server error', message: err.message });
  }
});

// GET /dashboard/charts - Chart data
router.get('/charts', async (req, res) => {
  try {
    const dbAvailable = await checkConnection();
    if (dbAvailable) {
      // Placeholder for stored procedure call
      res.json({
        monthly: mockData.monthlyChartData,
        claimsByCategory: mockData.claimsByCategory,
      });
    } else {
      res.json({
        monthly: mockData.monthlyChartData,
        claimsByCategory: mockData.claimsByCategory,
      });
    }
  } catch (err) {
    console.error('Error fetching dashboard charts:', err);
    res.status(500).json({ error: 'Internal server error', message: err.message });
  }
});

// GET /dashboard/activities - Recent activity feed
router.get('/activities', async (req, res) => {
  try {
    const dbAvailable = await checkConnection();
    const page = parseInt(req.query.page) || 1;
    const limit = parseInt(req.query.limit) || 10;

    if (dbAvailable) {
      // Placeholder for stored procedure call
      // const result = await pool.request()
      //   .input('Page', sql.Int, page)
      //   .input('Limit', sql.Int, limit)
      //   .execute('sp_Dashboard_GetActivities');
      res.json(mockData.paginate(mockData.recentActivities, page, limit));
    } else {
      res.json(mockData.paginate(mockData.recentActivities, page, limit));
    }
  } catch (err) {
    console.error('Error fetching activities:', err);
    res.status(500).json({ error: 'Internal server error', message: err.message });
  }
});

// GET /dashboard/alerts - Expiring contracts & urgent claims
router.get('/alerts', async (req, res) => {
  try {
    const dbAvailable = await checkConnection();
    if (dbAvailable) {
      // Placeholder for stored procedure call
      res.json({
        expiringContracts: mockData.expiringContracts,
        urgentClaims: mockData.openClaimsSummary.filter(c => c.urgent),
      });
    } else {
      res.json({
        expiringContracts: mockData.expiringContracts,
        urgentClaims: mockData.openClaimsSummary.filter(c => c.urgent),
      });
    }
  } catch (err) {
    console.error('Error fetching alerts:', err);
    res.status(500).json({ error: 'Internal server error', message: err.message });
  }
});

module.exports = router;
