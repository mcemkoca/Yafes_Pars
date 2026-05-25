/**
 * Personen Routes
 * GET /api/v1/personen?page=&limit=&search=&type=&stad=
 * GET /api/v1/personen/:id
 * POST /api/v1/personen
 * PUT /api/v1/personen/:id
 * DELETE /api/v1/personen/:id
 */
const express = require('express');
const router = express.Router();
const { pool, sql, checkConnection } = require('../db');
const mockData = require('../mockData');

// GET /personen - List with filters
router.get('/', async (req, res) => {
  try {
    const dbAvailable = await checkConnection();
    const page = parseInt(req.query.page) || 1;
    const limit = parseInt(req.query.limit) || 20;
    const search = req.query.search || '';
    const type = req.query.type || '';
    const stad = req.query.stad || '';

    if (dbAvailable) {
      try {
        const result = await pool.request()
          .input('Page', sql.Int, page)
          .input('Limit', sql.Int, limit)
          .input('Search', sql.NVarChar(255), search)
          .input('Type', sql.NVarChar(50), type)
          .input('Stad', sql.NVarChar(100), stad)
          .execute('sp_Person_GetAll');
        res.json({
          data: result.recordset,
          pagination: { page, limit, total: result.recordset.length }
        });
        return;
      } catch (spErr) {
        console.warn('Stored procedure failed, falling back to mock data:', spErr.message);
      }
    }

    // Mock data fallback with filtering
    let filtered = [...mockData.persons];
    if (search) {
      filtered = mockData.filterBySearch(filtered, search, ['voornaam', 'achternaam', 'naam', 'email', 'telefoon', 'gemeente', 'rrn']);
    }
    if (type) {
      filtered = filtered.filter(p => p.type === type);
    }
    if (stad) {
      filtered = filtered.filter(p => (p.gemeente || '').toLowerCase().includes(stad.toLowerCase()));
    }
    res.json(mockData.paginate(filtered, page, limit));
  } catch (err) {
    console.error('Error fetching persons:', err);
    res.status(500).json({ error: 'Internal server error', message: err.message });
  }
});

// GET /personen/:id - Detail
router.get('/:id', async (req, res) => {
  try {
    const dbAvailable = await checkConnection();
    const { id } = req.params;

    if (dbAvailable) {
      try {
        const result = await pool.request()
          .input('Id', sql.NVarChar(50), id)
          .execute('sp_Person_GetById');
        if (result.recordset.length === 0) {
          return res.status(404).json({ error: 'Person not found' });
        }
        res.json(result.recordset[0]);
        return;
      } catch (spErr) {
        console.warn('Stored procedure failed, falling back to mock data:', spErr.message);
      }
    }

    const person = mockData.persons.find(p => p.id === id);
    if (!person) {
      return res.status(404).json({ error: 'Person not found' });
    }
    res.json(person);
  } catch (err) {
    console.error('Error fetching person:', err);
    res.status(500).json({ error: 'Internal server error', message: err.message });
  }
});

// POST /personen - Create
router.post('/', async (req, res) => {
  try {
    const dbAvailable = await checkConnection();
    const personData = req.body;

    if (dbAvailable) {
      try {
        const result = await pool.request()
          .input('Type', sql.NVarChar(50), personData.type)
          .input('Voornaam', sql.NVarChar(100), personData.voornaam)
          .input('Achternaam', sql.NVarChar(100), personData.achternaam)
          .input('Naam', sql.NVarChar(200), personData.naam)
          .input('RRN', sql.NVarChar(50), personData.rrn)
          .input('Geboortedatum', sql.Date, personData.geboortedatum)
          .input('Geslacht', sql.NVarChar(10), personData.geslacht)
          .input('Email', sql.NVarChar(255), personData.email)
          .input('Telefoon', sql.NVarChar(50), personData.telefoon)
          .input('Adres', sql.NVarChar(255), personData.adres)
          .input('Postcode', sql.NVarChar(20), personData.postcode)
          .input('Gemeente', sql.NVarChar(100), personData.gemeente)
          .input('Land', sql.NVarChar(100), personData.land)
          .input('Status', sql.NVarChar(50), personData.status || 'actief')
          .execute('sp_Person_Create');
        res.status(201).json({ id: result.recordset[0]?.id, message: 'Person created successfully' });
        return;
      } catch (spErr) {
        console.warn('Stored procedure failed, using mock:', spErr.message);
      }
    }

    const newId = `P-2024-${String(mockData.persons.length + 1).padStart(4, '0')}`;
    const newPerson = { ...personData, id: newId, createdAt: new Date().toISOString(), updatedAt: new Date().toISOString() };
    mockData.persons.push(newPerson);
    res.status(201).json({ id: newId, message: 'Person created successfully', data: newPerson });
  } catch (err) {
    console.error('Error creating person:', err);
    res.status(500).json({ error: 'Internal server error', message: err.message });
  }
});

// PUT /personen/:id - Update
router.put('/:id', async (req, res) => {
  try {
    const dbAvailable = await checkConnection();
    const { id } = req.params;
    const personData = req.body;

    if (dbAvailable) {
      try {
        await pool.request()
          .input('Id', sql.NVarChar(50), id)
          .input('Voornaam', sql.NVarChar(100), personData.voornaam)
          .input('Achternaam', sql.NVarChar(100), personData.achternaam)
          .input('Naam', sql.NVarChar(200), personData.naam)
          .input('Email', sql.NVarChar(255), personData.email)
          .input('Telefoon', sql.NVarChar(50), personData.telefoon)
          .input('Adres', sql.NVarChar(255), personData.adres)
          .input('Postcode', sql.NVarChar(20), personData.postcode)
          .input('Gemeente', sql.NVarChar(100), personData.gemeente)
          .input('Status', sql.NVarChar(50), personData.status)
          .execute('sp_Person_Update');
        res.json({ message: 'Person updated successfully' });
        return;
      } catch (spErr) {
        console.warn('Stored procedure failed, using mock:', spErr.message);
      }
    }

    const idx = mockData.persons.findIndex(p => p.id === id);
    if (idx === -1) {
      return res.status(404).json({ error: 'Person not found' });
    }
    mockData.persons[idx] = { ...mockData.persons[idx], ...personData, updatedAt: new Date().toISOString() };
    res.json({ message: 'Person updated successfully', data: mockData.persons[idx] });
  } catch (err) {
    console.error('Error updating person:', err);
    res.status(500).json({ error: 'Internal server error', message: err.message });
  }
});

// DELETE /personen/:id - Soft delete
router.delete('/:id', async (req, res) => {
  try {
    const dbAvailable = await checkConnection();
    const { id } = req.params;

    if (dbAvailable) {
      try {
        await pool.request()
          .input('Id', sql.NVarChar(50), id)
          .execute('sp_Person_Delete');
        res.json({ message: 'Person deleted successfully' });
        return;
      } catch (spErr) {
        console.warn('Stored procedure failed, using mock:', spErr.message);
      }
    }

    const idx = mockData.persons.findIndex(p => p.id === id);
    if (idx === -1) {
      return res.status(404).json({ error: 'Person not found' });
    }
    mockData.persons[idx].status = 'inactief';
    mockData.persons[idx].updatedAt = new Date().toISOString();
    res.json({ message: 'Person deleted successfully' });
  } catch (err) {
    console.error('Error deleting person:', err);
    res.status(500).json({ error: 'Internal server error', message: err.message });
  }
});

module.exports = router;
