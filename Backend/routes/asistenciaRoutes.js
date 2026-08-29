const express = require('express');
const router = express.Router();
const { verificarToken, soloOperador, soloAdmin } = require('../middleware/auth');
const { checkInLimiter } = require('../middleware/rateLimiter');
const {
  checkInQR,
  checkInManual,
  reporte,
} = require('../controllers/asistenciaController');


router.post('/check-in-qr', verificarToken, checkInLimiter, checkInQR);


router.post('/eventos/:id/asistencia-manual', verificarToken, soloOperador, checkInManual);


router.get('/eventos/:id/reporte', verificarToken, soloAdmin, reporte);

module.exports = router;