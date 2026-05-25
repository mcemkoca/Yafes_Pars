/**
 * Route Aggregator
 * Combines all route modules under /api/v1
 */
const express = require('express');
const router = express.Router();

router.use('/dashboard', require('./dashboard'));
router.use('/personen', require('./personen'));
router.use('/instellingen', require('./instellingen'));
router.use('/objecten', require('./objecten'));
router.use('/contracten', require('./contracten'));
router.use('/schadeclaims', require('./schadeclaims'));
router.use('/rapporten', require('./rapporten'));
router.use('/beheer', require('./beheer'));

// Health check endpoint
router.get('/health', (req, res) => {
  res.json({
    status: 'ok',
    service: 'AssureManager API',
    version: '1.0.0',
    timestamp: new Date().toISOString(),
  });
});

module.exports = router;
