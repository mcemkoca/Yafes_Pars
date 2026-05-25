/**
 * Contracten Routes
 * GET /api/v1/contracten?page=&limit=&status=&search=&domein=
 * GET /api/v1/contracten/:id
 * POST /api/v1/contracten
 * PUT /api/v1/contracten/:id
 * DELETE /api/v1/contracten/:id
 */
const express = require('express');
const router = express.Router();
const { pool, sql, checkConnection } = require('../db');
const mockData = require('../mockData');

// GET /contracten - List with status and domain filters
router.get('/', async (req, res) => {
  try {
    const dbAvailable = await checkConnection();
    const page = parseInt(req.query.page) || 1;
    const limit = parseInt(req.query.limit) || 20;
    const status = req.query.status || '';
    const domein = req.query.domein || '';
    const search = req.query.search || '';

    if (dbAvailable) {
      try {
        const result = await pool.request()
          .input('Page', sql.Int, page)
          .input('Limit', sql.Int, limit)
          .input('Status', sql.NVarChar(50), status)
          .input('Domein', sql.NVarChar(50), domein)
          .input('Search', sql.NVarChar(255), search)
          .execute('sp_Contract_GetAll');
        res.json({
          data: result.recordset,
          pagination: { page, limit, total: result.recordset.length }
        });
        return;
      } catch (spErr) {
        console.warn('Stored procedure failed, falling back to mock data:', spErr.message);
      }
    }

    let filtered = [...mockData.contracts];
    if (status) {
      filtered = filtered.filter(c => c.status === status);
    }
    if (domein) {
      filtered = filtered.filter(c => c.domein === domein);
    }
    if (search) {
      filtered = mockData.filterBySearch(filtered, search, ['contractnummer', 'product', 'verzekerdeNamen']);
    }
    res.json(mockData.paginate(filtered, page, limit));
  } catch (err) {
    console.error('Error fetching contracts:', err);
    res.status(500).json({ error: 'Internal server error', message: err.message });
  }
});

// GET /contracten/:id - Detail
router.get('/:id', async (req, res) => {
  try {
    const dbAvailable = await checkConnection();
    const { id } = req.params;

    if (dbAvailable) {
      try {
        const result = await pool.request()
          .input('Id', sql.NVarChar(50), id)
          .execute('sp_Contract_GetById');
        if (result.recordset.length === 0) {
          return res.status(404).json({ error: 'Contract not found' });
        }
        res.json(result.recordset[0]);
        return;
      } catch (spErr) {
        console.warn('Stored procedure failed, falling back to mock data:', spErr.message);
      }
    }

    const contract = mockData.contracts.find(c => c.id === id);
    if (!contract) {
      return res.status(404).json({ error: 'Contract not found' });
    }
    // Enrich with institution and object details
    const maatschappij = mockData.institutions.find(i => i.id === contract.maatschappijId);
    const object = mockData.allObjects.find(o => o.id === contract.objectId);
    res.json({ ...contract, maatschappij, object });
  } catch (err) {
    console.error('Error fetching contract:', err);
    res.status(500).json({ error: 'Internal server error', message: err.message });
  }
});

// POST /contracten - Create
router.post('/', async (req, res) => {
  try {
    const dbAvailable = await checkConnection();
    const data = req.body;

    if (dbAvailable) {
      try {
        const result = await pool.request()
          .input('Contractnummer', sql.NVarChar(100), data.contractnummer)
          .input('Domein', sql.NVarChar(50), data.domein)
          .input('Status', sql.NVarChar(50), data.status)
          .input('Product', sql.NVarChar(200), data.product)
          .input('MaatschappijId', sql.NVarChar(50), data.maatschappijId)
          .input('Premie', sql.Decimal(18, 2), data.premie)
          .input('Provisie', sql.Decimal(18, 2), data.provisie)
          .input('Startdatum', sql.Date, data.startdatum)
          .input('Einddatum', sql.Date, data.einddatum)
          .input('VerzekerdeNamen', sql.NVarChar(sql.MAX), JSON.stringify(data.verzekerdeNamen))
          .input('ObjectId', sql.NVarChar(50), data.objectId)
          .execute('sp_Contract_Create');
        res.status(201).json({ id: result.recordset[0]?.id, message: 'Contract created successfully' });
        return;
      } catch (spErr) {
        console.warn('Stored procedure failed, using mock:', spErr.message);
      }
    }

    const newId = `C-${String(mockData.contracts.length + 1).padStart(3, '0')}`;
    const newContract = { ...data, id: newId, createdAt: new Date().toISOString() };
    mockData.contracts.push(newContract);
    res.status(201).json({ id: newId, message: 'Contract created successfully', data: newContract });
  } catch (err) {
    console.error('Error creating contract:', err);
    res.status(500).json({ error: 'Internal server error', message: err.message });
  }
});

// PUT /contracten/:id - Update
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
          .input('Product', sql.NVarChar(200), data.product)
          .input('Premie', sql.Decimal(18, 2), data.premie)
          .input('Provisie', sql.Decimal(18, 2), data.provisie)
          .input('Startdatum', sql.Date, data.startdatum)
          .input('Einddatum', sql.Date, data.einddatum)
          .input('VerzekerdeNamen', sql.NVarChar(sql.MAX), JSON.stringify(data.verzekerdeNamen))
          .execute('sp_Contract_Update');
        res.json({ message: 'Contract updated successfully' });
        return;
      } catch (spErr) {
        console.warn('Stored procedure failed, using mock:', spErr.message);
      }
    }

    const idx = mockData.contracts.findIndex(c => c.id === id);
    if (idx === -1) {
      return res.status(404).json({ error: 'Contract not found' });
    }
    mockData.contracts[idx] = { ...mockData.contracts[idx], ...data };
    res.json({ message: 'Contract updated successfully', data: mockData.contracts[idx] });
  } catch (err) {
    console.error('Error updating contract:', err);
    res.status(500).json({ error: 'Internal server error', message: err.message });
  }
});

// DELETE /contracten/:id - Delete
router.delete('/:id', async (req, res) => {
  try {
    const dbAvailable = await checkConnection();
    const { id } = req.params;

    if (dbAvailable) {
      try {
        await pool.request()
          .input('Id', sql.NVarChar(50), id)
          .execute('sp_Contract_Delete');
        res.json({ message: 'Contract deleted successfully' });
        return;
      } catch (spErr) {
        console.warn('Stored procedure failed, using mock:', spErr.message);
      }
    }

    const idx = mockData.contracts.findIndex(c => c.id === id);
    if (idx === -1) {
      return res.status(404).json({ error: 'Contract not found' });
    }
    mockData.contracts.splice(idx, 1);
    res.json({ message: 'Contract deleted successfully' });
  } catch (err) {
    console.error('Error deleting contract:', err);
    res.status(500).json({ error: 'Internal server error', message: err.message });
  }
});

module.exports = router;
