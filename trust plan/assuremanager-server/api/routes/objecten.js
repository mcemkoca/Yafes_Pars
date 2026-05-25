/**
 * Objecten Routes
 * GET /api/v1/objecten?page=&limit=&category=&search=
 * GET /api/v1/objecten/:id
 * POST /api/v1/objecten
 * PUT /api/v1/objecten/:id
 * DELETE /api/v1/objecten/:id
 */
const express = require('express');
const router = express.Router();
const { pool, sql, checkConnection } = require('../db');
const mockData = require('../mockData');

// GET /objecten - List with category filter
router.get('/', async (req, res) => {
  try {
    const dbAvailable = await checkConnection();
    const page = parseInt(req.query.page) || 1;
    const limit = parseInt(req.query.limit) || 20;
    const category = req.query.category || '';
    const search = req.query.search || '';

    if (dbAvailable) {
      try {
        const result = await pool.request()
          .input('Page', sql.Int, page)
          .input('Limit', sql.Int, limit)
          .input('Category', sql.NVarChar(50), category)
          .input('Search', sql.NVarChar(255), search)
          .execute('sp_Object_GetAll');
        res.json({
          data: result.recordset,
          pagination: { page, limit, total: result.recordset.length }
        });
        return;
      } catch (spErr) {
        console.warn('Stored procedure failed, falling back to mock data:', spErr.message);
      }
    }

    let filtered = [...mockData.allObjects];
    if (category) {
      filtered = filtered.filter(o => o.category === category);
    }
    if (search) {
      filtered = filtered.filter(o => {
        const s = search.toLowerCase();
        return JSON.stringify(o).toLowerCase().includes(s);
      });
    }
    res.json(mockData.paginate(filtered, page, limit));
  } catch (err) {
    console.error('Error fetching objects:', err);
    res.status(500).json({ error: 'Internal server error', message: err.message });
  }
});

// GET /objecten/:id - Detail
router.get('/:id', async (req, res) => {
  try {
    const dbAvailable = await checkConnection();
    const { id } = req.params;

    if (dbAvailable) {
      try {
        const result = await pool.request()
          .input('Id', sql.NVarChar(50), id)
          .execute('sp_Object_GetById');
        if (result.recordset.length === 0) {
          return res.status(404).json({ error: 'Object not found' });
        }
        res.json(result.recordset[0]);
        return;
      } catch (spErr) {
        console.warn('Stored procedure failed, falling back to mock data:', spErr.message);
      }
    }

    const obj = mockData.allObjects.find(o => o.id === id);
    if (!obj) {
      return res.status(404).json({ error: 'Object not found' });
    }
    res.json(obj);
  } catch (err) {
    console.error('Error fetching object:', err);
    res.status(500).json({ error: 'Internal server error', message: err.message });
  }
});

// POST /objecten - Create
router.post('/', async (req, res) => {
  try {
    const dbAvailable = await checkConnection();
    const data = req.body;

    if (dbAvailable) {
      try {
        const result = await pool.request()
          .input('Category', sql.NVarChar(50), data.category)
          .input('Data', sql.NVarChar(sql.MAX), JSON.stringify(data))
          .execute('sp_Object_Create');
        res.status(201).json({ id: result.recordset[0]?.id, message: 'Object created successfully' });
        return;
      } catch (spErr) {
        console.warn('Stored procedure failed, using mock:', spErr.message);
      }
    }

    const prefix = {
      voertuig: 'O-V',
      vastgoed: 'O-R',
      lening: 'O-L',
      ding: 'O-T',
      activiteit: 'O-A'
    }[data.category] || 'O-X';
    const count = mockData.allObjects.filter(o => o.category === data.category).length;
    const newId = `${prefix}-${String(count + 1).padStart(3, '0')}`;
    const newObj = { ...data, id: newId };
    mockData.allObjects.push(newObj);
    res.status(201).json({ id: newId, message: 'Object created successfully', data: newObj });
  } catch (err) {
    console.error('Error creating object:', err);
    res.status(500).json({ error: 'Internal server error', message: err.message });
  }
});

// PUT /objecten/:id - Update
router.put('/:id', async (req, res) => {
  try {
    const dbAvailable = await checkConnection();
    const { id } = req.params;
    const data = req.body;

    if (dbAvailable) {
      try {
        await pool.request()
          .input('Id', sql.NVarChar(50), id)
          .input('Data', sql.NVarChar(sql.MAX), JSON.stringify(data))
          .execute('sp_Object_Update');
        res.json({ message: 'Object updated successfully' });
        return;
      } catch (spErr) {
        console.warn('Stored procedure failed, using mock:', spErr.message);
      }
    }

    const idx = mockData.allObjects.findIndex(o => o.id === id);
    if (idx === -1) {
      return res.status(404).json({ error: 'Object not found' });
    }
    mockData.allObjects[idx] = { ...mockData.allObjects[idx], ...data };
    res.json({ message: 'Object updated successfully', data: mockData.allObjects[idx] });
  } catch (err) {
    console.error('Error updating object:', err);
    res.status(500).json({ error: 'Internal server error', message: err.message });
  }
});

// DELETE /objecten/:id - Delete
router.delete('/:id', async (req, res) => {
  try {
    const dbAvailable = await checkConnection();
    const { id } = req.params;

    if (dbAvailable) {
      try {
        await pool.request()
          .input('Id', sql.NVarChar(50), id)
          .execute('sp_Object_Delete');
        res.json({ message: 'Object deleted successfully' });
        return;
      } catch (spErr) {
        console.warn('Stored procedure failed, using mock:', spErr.message);
      }
    }

    const idx = mockData.allObjects.findIndex(o => o.id === id);
    if (idx === -1) {
      return res.status(404).json({ error: 'Object not found' });
    }
    mockData.allObjects.splice(idx, 1);
    res.json({ message: 'Object deleted successfully' });
  } catch (err) {
    console.error('Error deleting object:', err);
    res.status(500).json({ error: 'Internal server error', message: err.message });
  }
});

module.exports = router;
