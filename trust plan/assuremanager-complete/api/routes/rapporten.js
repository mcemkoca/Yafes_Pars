/**
 * Rapporten Routes
 * GET /api/v1/rapporten/commissions
 * GET /api/v1/rapporten/contracts
 * GET /api/v1/rapporten/claims
 * GET /api/v1/rapporten/clients
 */
const express = require('express');
const router = express.Router();
const { pool, sql, checkConnection } = require('../db');
const mockData = require('../mockData');

// GET /rapporten/commissions - Commission data
router.get('/commissions', async (req, res) => {
  try {
    const dbAvailable = await checkConnection();
    const periode = req.query.periode || 'huidig_jaar';

    if (dbAvailable) {
      try {
        const result = await pool.request()
          .input('Periode', sql.NVarChar(50), periode)
          .execute('sp_Rapporten_Commissions');
        res.json(result.recordset);
        return;
      } catch (spErr) {
        console.warn('Stored procedure failed, falling back to mock data:', spErr.message);
      }
    }

    // Generate commission report from mock contracts
    const commissions = mockData.contracts.map(c => ({
      contractnummer: c.contractnummer,
      product: c.product,
      domein: c.domein,
      maatschappij: mockData.institutions.find(i => i.id === c.maatschappijId)?.naam || 'Onbekend',
      premie: c.premie,
      provisie: c.provisie,
      provisiePercentage: c.premie > 0 ? ((c.provisie / c.premie) * 100).toFixed(1) : '0.0',
      verzekerde: Array.isArray(c.verzekerdeNamen) ? c.verzekerdeNamen.join(', ') : (c.verzekerdeNamen || ''),
      startdatum: c.startdatum,
      einddatum: c.einddatum,
      status: c.status,
    }));

    const totalPremie = commissions.reduce((s, c) => s + c.premie, 0);
    const totalProvisie = commissions.reduce((s, c) => s + c.provisie, 0);

    res.json({
      periode,
      samenvatting: {
        totaalPremie: totalPremie,
        totaalProvisie: totalProvisie,
        gemiddeldeProvisiePct: totalPremie > 0 ? ((totalProvisie / totalPremie) * 100).toFixed(1) : '0.0',
        aantalContracten: commissions.length,
      },
      details: commissions,
    });
  } catch (err) {
    console.error('Error fetching commission report:', err);
    res.status(500).json({ error: 'Internal server error', message: err.message });
  }
});

// GET /rapporten/contracts - Contract analytics
router.get('/contracts', async (req, res) => {
  try {
    const dbAvailable = await checkConnection();

    if (dbAvailable) {
      try {
        const result = await pool.request()
          .execute('sp_Rapporten_Contracts');
        res.json(result.recordset);
        return;
      } catch (spErr) {
        console.warn('Stored procedure failed, falling back to mock data:', spErr.message);
      }
    }

    // Aggregate contract analytics
    const byDomain = {};
    const byStatus = {};
    const byCompany = {};
    let totalPremie = 0;
    let totalProvisie = 0;

    mockData.contracts.forEach(c => {
      byDomain[c.domein] = (byDomain[c.domein] || 0) + 1;
      byStatus[c.status] = (byStatus[c.status] || 0) + 1;
      const m = mockData.institutions.find(i => i.id === c.maatschappijId);
      const key = m ? m.naam : 'Onbekend';
      byCompany[key] = (byCompany[key] || 0) + 1;
      if (c.status === 'actief') {
        totalPremie += c.premie;
        totalProvisie += c.provisie;
      }
    });

    res.json({
      samenvatting: {
        totaalContracten: mockData.contracts.length,
        actieveContracten: mockData.contracts.filter(c => c.status === 'actief').length,
        vervallenContracten: mockData.contracts.filter(c => c.status === 'vervallen').length,
        totaalPremie: totalPremie,
        totaalProvisie: totalProvisie,
      },
      perDomein: Object.entries(byDomain).map(([naam, aantal]) => ({ naam, aantal })),
      perStatus: Object.entries(byStatus).map(([naam, aantal]) => ({ naam, aantal })),
      perMaatschappij: Object.entries(byCompany).map(([naam, aantal]) => ({ naam, aantal })),
    });
  } catch (err) {
    console.error('Error fetching contract analytics:', err);
    res.status(500).json({ error: 'Internal server error', message: err.message });
  }
});

// GET /rapporten/claims - Claims analytics
router.get('/claims', async (req, res) => {
  try {
    const dbAvailable = await checkConnection();

    if (dbAvailable) {
      try {
        const result = await pool.request()
          .execute('sp_Rapporten_Claims');
        res.json(result.recordset);
        return;
      } catch (spErr) {
        console.warn('Stored procedure failed, falling back to mock data:', spErr.message);
      }
    }

    const byCategory = {};
    const byStatus = {};
    const byUrgency = {};
    let totalBedrag = 0;
    let openBedrag = 0;

    mockData.claims.forEach(c => {
      byCategory[c.categorie] = (byCategory[c.categorie] || 0) + 1;
      byStatus[c.status] = (byStatus[c.status] || 0) + 1;
      byUrgency[c.urgentie] = (byUrgency[c.urgentie] || 0) + 1;
      totalBedrag += c.bedrag;
      if (c.status !== 'afgesloten' && c.status !== 'afgekeurd') {
        openBedrag += c.bedrag;
      }
    });

    res.json({
      samenvatting: {
        totaalClaims: mockData.claims.length,
        openClaims: mockData.claims.filter(c => c.status !== 'afgesloten' && c.status !== 'afgekeurd').length,
        totaalBedrag: totalBedrag,
        openBedrag,
        gemiddeldBedrag: mockData.claims.length > 0 ? totalBedrag / mockData.claims.length : 0,
      },
      perCategorie: Object.entries(byCategory).map(([naam, aantal]) => ({ naam, aantal })),
      perStatus: Object.entries(byStatus).map(([naam, aantal]) => ({ naam, aantal })),
      perUrgentie: Object.entries(byUrgency).map(([naam, aantal]) => ({ naam, aantal })),
    });
  } catch (err) {
    console.error('Error fetching claims analytics:', err);
    res.status(500).json({ error: 'Internal server error', message: err.message });
  }
});

// GET /rapporten/clients - Client demographics
router.get('/clients', async (req, res) => {
  try {
    const dbAvailable = await checkConnection();

    if (dbAvailable) {
      try {
        const result = await pool.request()
          .execute('sp_Rapporten_Clients');
        res.json(result.recordset);
        return;
      } catch (spErr) {
        console.warn('Stored procedure failed, falling back to mock data:', spErr.message);
      }
    }

    const byType = {};
    const byStatus = {};
    const byCity = {};
    const byGender = {};

    mockData.persons.forEach(p => {
      byType[p.type] = (byType[p.type] || 0) + 1;
      byStatus[p.status] = (byStatus[p.status] || 0) + 1;
      byCity[p.gemeente] = (byCity[p.gemeente] || 0) + 1;
      if (p.geslacht) {
        byGender[p.geslacht] = (byGender[p.geslacht] || 0) + 1;
      }
    });

    // Calculate average contracts per person
    const contractsPerPerson = {};
    mockData.contracts.forEach(c => {
      if (Array.isArray(c.verzekerdeNamen)) {
        c.verzekerdeNamen.forEach(n => {
          contractsPerPerson[n] = (contractsPerPerson[n] || 0) + 1;
        });
      }
    });
    const personCount = Object.keys(contractsPerPerson).length;
    const avgContracts = personCount > 0
      ? Object.values(contractsPerPerson).reduce((s, v) => s + v, 0) / personCount
      : 0;

    res.json({
      samenvatting: {
        totaalPersonen: mockData.persons.length,
        natuurlijkePersonen: mockData.persons.filter(p => p.type === 'natuurlijk').length,
        rechtspersonen: mockData.persons.filter(p => p.type === 'rechtspersoon').length,
        prospecten: mockData.persons.filter(p => p.status === 'prospect').length,
        gemiddeldContractenPerPersoon: avgContracts.toFixed(1),
      },
      perType: Object.entries(byType).map(([naam, aantal]) => ({ naam, aantal })),
      perStatus: Object.entries(byStatus).map(([naam, aantal]) => ({ naam, aantal })),
      perGemeente: Object.entries(byCity).map(([naam, aantal]) => ({ naam, aantal })).sort((a, b) => b.aantal - a.aantal),
      perGeslacht: Object.entries(byGender).map(([naam, aantal]) => ({ naam: naam === 'M' ? 'Man' : naam === 'V' ? 'Vrouw' : 'Onbekend', aantal })),
      topPersonenMetContracten: Object.entries(contractsPerPerson)
        .sort((a, b) => b[1] - a[1])
        .slice(0, 10)
        .map(([naam, aantal]) => ({ naam, aantal })),
    });
  } catch (err) {
    console.error('Error fetching client demographics:', err);
    res.status(500).json({ error: 'Internal server error', message: err.message });
  }
});

module.exports = router;
