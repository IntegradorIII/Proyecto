const express = require('express');
const router = express.Router();
const { verificarToken, soloOperador, soloAdmin } = require('../middleware/auth');
const { checkInQR, checkInInvitado, checkInManual, reporte } = require('../controllers/asistenciaController');

router.post('/check-in-qr', verificarToken, soloOperador, checkInQR);
router.post('/check-in-invitado', verificarToken, soloOperador, checkInInvitado);
router.post('/eventos/:id/asistencia-manual', verificarToken, soloOperador, checkInManual);
router.get('/eventos/:id/reporte', verificarToken, soloAdmin, reporte);

module.exports = router;