/**
 * Instellingen (Institutions) Routes
 * GET /api/v1/instellingen?page=&limit=&search=&type=
 * GET /api/v1/instellingen/:id
 * POST /api/v1/instellingen
 * PUT /api/v1/instellingen/:id
 * DELETE /api/v1/instellingen/:id
 */
const express = require('express');
const router = express.Router();
const { pool, sql, checkConnection } = require('../db');
const mockData = require('../mockData');

// GET /instellingen - List with filters
router.get('/', async (req, res) => {
  try {
    const dbAvailable = await checkConnection();
    const page = parseInt(req.query.page) || 1;
    const limit = parseInt(req.query.limit) || 20;
    const search = req.query.search || '';
    const type = req.query.type || '';

    if (dbAvailable) {
      try {
        const result = await pool.request()
          .input('Page', sql.Int, page)
          .input('Limit', sql.Int, limit)
          .input('Search', sql.NVarChar(255), search)
          .input('Type', sql.NVarChar(50), type)
          .execute('sp_Institution_GetAll');
        res.json({
          data: result.recordset,
          pagination: { page, limit, total: result.recordset.length }
        });
        return;
      } catch (spErr) {
        console.warn('Stored procedure failed, falling back to mock data:', spErr.message);
      }
    }

    let filtered = [...mockData.institutions];
    if (search) {
      filtered = mockData.filterBySearch(filtered, search, ['naam', 'kbo', 'email', 'gemeente', 'telefoon']);
    }
    if (type) {
      filtered = filtered.filter(i => i.type === type);
    }
    res.json(mockData.paginate(filtered, page, limit));
  } catch (err) {
    console.error('Error fetching institutions:', err);
    res.status(500).json({ error: 'Internal server error', message: err.message });
  }
});

// GET /instellingen/:id - Detail
router.get('/:id', async (req, res) => {
  try {
    const dbAvailable = await checkConnection();
    const { id } = req.params;

    if (dbAvailable) {
      try {
        const result = await pool.request()
          .input('Id', sql.NVarChar(50), id)
          .execute('sp_Institution_GetById');
        if (result.recordset.length === 0) {
          return res.status(404).json({ error: 'Institution not found' });
        }
        res.json(result.recordset[0]);
        return;
      } catch (spErr) {
        console.warn('Stored procedure failed, falling back to mock data:', spErr.message);
      }
    }

    const institution = mockData.institutions.find(i => i.id === id);
    if (!institution) {
      return res.status(404).json({ error: 'Institution not found' });
    }
    res.json(institution);
  } catch (err) {
    console.error('Error fetching institution:', err);
    res.status(500).json({ error: 'Internal server error', message: err.message });
  }
});

// POST /instellingen - Create
router.post('/', async (req, res) => {
  try {
    const dbAvailable = await checkConnection();
    const data = req.body;

    if (dbAvailable) {
      try {
        const result = await pool.request()
          .input('Naam', sql.NVarChar(200), data.naam)
          .input('Type', sql.NVarChar(50), data.type)
          .input('KBO', sql.NVarChar(50), data.kbo)
          .input('Adres', sql.NVarChar(255), data.adres)
          .input('Postcode', sql.NVarChar(20), data.postcode)
          .input('Gemeente', sql.NVarChar(100), data.gemeente)
          .input('Email', sql.NVarChar(255), data.email)
          .input('Telefoon', sql.NVarChar(50), data.telefoon)
          .execute('sp_Institution_Create');
        res.status(201).json({ id: result.recordset[0]?.id, message: 'Institution created successfully' });
        return;
      } catch (spErr) {
        console.warn('Stored procedure failed, using mock:', spErr.message);
      }
    }

    const newId = `I-${String(mockData.institutions.length + 1).padStart(3, '0')}`;
    const newInst = { ...data, id: newId, createdAt: new Date().toISOString() };
    mockData.institutions.push(newInst);
    res.status(201).json({ id: newId, message: 'Institution created successfully', data: newInst });
  } catch (err) {
    console.error('Error creating institution:', err);
    res.status(500).json({ error: 'Internal server error', message: err.message });
  }
});

// PUT /instellingen/:id - Update
router.put('/:id', async (req, res) => {
  try {
    const dbAvailable = await checkConnection();
    const { id } = req.params;
    const data = req.body;

    if (dbAvailable) {
      try {
        await pool.request()
          .input('Id', sql.NVarChar(50), id)
          .input('Naam', sql.NVarChar(200), data.naam)
          .input('Type', sql.NVarChar(50), data.type)
          .input('KBO', sql.NVarChar(50), data.kbo)
          .input('Adres', sql.NVarChar(255), data.adres)
          .input('Postcode', sql.NVarChar(20), data.postcode)
          .input('Gemeente', sql.NVarChar(100), data.gemeente)
          .input('Email', sql.NVarChar(255), data.email)
          .input('Telefoon', sql.NVarChar(50), data.telefoon)
          .input('Status', sql.NVarChar(50), data.status)
          .execute('sp_Institution_Update');
        res.json({ message: 'Institution updated successfully' });
        return;
      } catch (spErr) {
        console.warn('Stored procedure failed, using mock:', spErr.message);
      }
    }

    const idx = mockData.institutions.findIndex(i => i.id === id);
    if (idx === -1) {
      return res.status(404).json({ error: 'Institution not found' });
    }
    mockData.institutions[idx] = { ...mockData.institutions[idx], ...data };
    res.json({ message: 'Institution updated successfully', data: mockData.institutions[idx] });
  } catch (err) {
    console.error('Error updating institution:', err);
    res.status(500).json({ error: 'Internal server error', message: err.message });
  }
});

// DELETE /instellingen/:id - Delete
router.delete('/:id', async (req, res) => {
  try {
    const dbAvailable = await checkConnection();
    const { id } = req.params;

    if (dbAvailable) {
      try {
        await pool.request()
          .input('Id', sql.NVarChar(50), id)
          .execute('sp_Institution_Delete');
        res.json({ message: 'Institution deleted successfully' });
        return;
      } catch (spErr) {
        console.warn('Stored procedure failed, using mock:', spErr.message);
      }
    }

    const idx = mockData.institutions.findIndex(i => i.id === id);
    if (idx === -1) {
      return res.status(404).json({ error: 'Institution not found' });
    }
    mockData.institutions.splice(idx, 1);
    res.json({ message: 'Institution deleted successfully' });
  } catch (err) {
    console.error('Error deleting institution:', err);
    res.status(500).json({ error: 'Internal server error', message: err.message });
  }
});

module.exports = router;
