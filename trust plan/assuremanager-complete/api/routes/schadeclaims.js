/**
 * Schadeclaims Routes
 * GET /api/v1/schadeclaims?page=&limit=&status=&search=&urgentie=
 * GET /api/v1/schadeclaims/:id
 * POST /api/v1/schadeclaims
 * PUT /api/v1/schadeclaims/:id
 * DELETE /api/v1/schadeclaims/:id
 */
const express = require('express');
const router = express.Router();
const { pool, sql, checkConnection } = require('../db');
const mockData = require('../mockData');

// GET /schadeclaims - List with status and urgency filters
router.get('/', async (req, res) => {
  try {
    const dbAvailable = await checkConnection();
    const page = parseInt(req.query.page) || 1;
    const limit = parseInt(req.query.limit) || 20;
    const status = req.query.status || '';
    const urgentie = req.query.urgentie || '';
    const search = req.query.search || '';

    if (dbAvailable) {
      try {
        const result = await pool.request()
          .input('Page', sql.Int, page)
          .input('Limit', sql.Int, limit)
          .input('Status', sql.NVarChar(50), status)
          .input('Urgentie', sql.NVarChar(50), urgentie)
          .input('Search', sql.NVarChar(255), search)
          .execute('sp_Claim_GetAll');
        res.json({
          data: result.recordset,
          pagination: { page, limit, total: result.recordset.length }
        });
        return;
      } catch (spErr) {
        console.warn('Stored procedure failed, falling back to mock data:', spErr.message);
      }
    }

    let filtered = [...mockData.claims];
    if (status) {
      filtered = filtered.filter(c => c.status === status);
    }
    if (urgentie) {
      filtered = filtered.filter(c => c.urgentie === urgentie);
    }
    if (search) {
      filtered = mockData.filterBySearch(filtered, search, ['claimnummer', 'verzekerdeNaam', 'categorie', 'beschrijving', 'contractnummer']);
    }
    res.json(mockData.paginate(filtered, page, limit));
  } catch (err) {
    console.error('Error fetching claims:', err);
    res.status(500).json({ error: 'Internal server error', message: err.message });
  }
});

// GET /schadeclaims/:id - Detail
router.get('/:id', async (req, res) => {
  try {
    const dbAvailable = await checkConnection();
    const { id } = req.params;

    if (dbAvailable) {
      try {
        const result = await pool.request()
          .input('Id', sql.NVarChar(50), id)
          .execute('sp_Claim_GetById');
        if (result.recordset.length === 0) {
          return res.status(404).json({ error: 'Claim not found' });
        }
        res.json(result.recordset[0]);
        return;
      } catch (spErr) {
        console.warn('Stored procedure failed, falling back to mock data:', spErr.message);
      }
    }

    const claim = mockData.claims.find(c => c.id === id);
    if (!claim) {
      return res.status(404).json({ error: 'Claim not found' });
    }
    res.json(claim);
  } catch (err) {
    console.error('Error fetching claim:', err);
    res.status(500).json({ error: 'Internal server error', message: err.message });
  }
});

// POST /schadeclaims - Create
router.post('/', async (req, res) => {
  try {
    const dbAvailable = await checkConnection();
    const data = req.body;

    if (dbAvailable) {
      try {
        const result = await pool.request()
          .input('Claimnummer', sql.NVarChar(100), data.claimnummer)
          .input('Contractnummer', sql.NVarChar(100), data.contractnummer)
          .input('Status', sql.NVarChar(50), data.status)
          .input('Categorie', sql.NVarChar(200), data.categorie)
          .input('Beschrijving', sql.NVarChar(sql.MAX), data.beschrijving)
          .input('DatumSchade', sql.Date, data.datumSchade)
          .input('DatumMelding', sql.Date, data.datumMelding)
          .input('Bedrag', sql.Decimal(18, 2), data.bedrag)
          .input('VerzekerdeNaam', sql.NVarChar(200), data.verzekerdeNaam)
          .input('Urgentie', sql.NVarChar(50), data.urgentie || 'normaal')
          .execute('sp_Claim_Create');
        res.status(201).json({ id: result.recordset[0]?.id, message: 'Claim created successfully' });
        return;
      } catch (spErr) {
        console.warn('Stored procedure failed, using mock:', spErr.message);
      }
    }

    const newId = `CL-${String(mockData.claims.length + 1).padStart(3, '0')}`;
    const newClaim = {
      ...data,
      id: newId,
      dagenOpen: Math.floor((new Date() - new Date(data.datumMelding)) / (1000 * 60 * 60 * 24)),
    };
    mockData.claims.push(newClaim);
    res.status(201).json({ id: newId, message: 'Claim created successfully', data: newClaim });
  } catch (err) {
    console.error('Error creating claim:', err);
    res.status(500).json({ error: 'Internal server error', message: err.message });
  }
});

// PUT /schadeclaims/:id - Update
router.put('/:id', async (req, res) => {
  try {
    const dbAvailable = await checkConnection();
    const { id } = req.params;
    const data = req.body;

    if (dbAvailable) {
      try {
        await pool.request()
          .input('Id', sql.NVarChar(50), id)
          .input('Status', sql.NVarChar(50), data.status)
          .input('Beschrijving', sql.NVarChar(sql.MAX), data.beschrijving)
          .input('Bedrag', sql.Decimal(18, 2), data.bedrag)
          .input('Urgentie', sql.NVarChar(50), data.urgentie)
          .execute('sp_Claim_Update');
        res.json({ message: 'Claim updated successfully' });
        return;
      } catch (spErr) {
        console.warn('Stored procedure failed, using mock:', spErr.message);
      }
    }

    const idx = mockData.claims.findIndex(c => c.id === id);
    if (idx === -1) {
      return res.status(404).json({ error: 'Claim not found' });
    }
    mockData.claims[idx] = { ...mockData.claims[idx], ...data };
    res.json({ message: 'Claim updated successfully', data: mockData.claims[idx] });
  } catch (err) {
    console.error('Error updating claim:', err);
    res.status(500).json({ error: 'Internal server error', message: err.message });
  }
});

// DELETE /schadeclaims/:id - Delete
router.delete('/:id', async (req, res) => {
  try {
    const dbAvailable = await checkConnection();
    const { id } = req.params;

    if (dbAvailable) {
      try {
        await pool.request()
          .input('Id', sql.NVarChar(50), id)
          .execute('sp_Claim_Delete');
        res.json({ message: 'Claim deleted successfully' });
        return;
      } catch (spErr) {
        console.warn('Stored procedure failed, using mock:', spErr.message);
      }
    }

    const idx = mockData.claims.findIndex(c => c.id === id);
    if (idx === -1) {
      return res.status(404).json({ error: 'Claim not found' });
    }
    mockData.claims.splice(idx, 1);
    res.json({ message: 'Claim deleted successfully' });
  } catch (err) {
    console.error('Error deleting claim:', err);
    res.status(500).json({ error: 'Internal server error', message: err.message });
  }
});

module.exports = router;
