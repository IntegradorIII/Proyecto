const express = require('express');
const router = express.Router();
const { checkInQR, checkInManual, reporte } = require('../controllers/asistenciaController');

router.post('/check-in-qr', checkInQR);
router.post('/eventos/:id/asistencia-manual', checkInManual);
router.get('/eventos/:id/reporte', reporte);

module.exports = router;