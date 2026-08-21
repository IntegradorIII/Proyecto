const express = require('express');
const router = express.Router();
const { verificarToken, soloOperador, soloAdmin } = require('../middleware/auth');
const { checkInLimiter } = require('../middleware/rateLimiter');
const {
  checkInQR,
  checkInInvitado,
  checkInManual,
  reporte,
} = require('../controllers/asistenciaController');

// Check-in por QR para cualquier usuario con cuenta convocada (Miembro, Operador, Admin)
router.post('/check-in-qr', verificarToken, checkInLimiter, checkInQR);

// Check-in de invitado externo (público para reuniones abiertas)
router.post('/check-in-invitado', checkInLimiter, checkInInvitado);

// Check-in manual realizado por Operador o Administrador
router.post('/eventos/:id/asistencia-manual', verificarToken, soloOperador, checkInManual);

// Reporte de asistencia (solo Administrador)
router.get('/eventos/:id/reporte', verificarToken, soloAdmin, reporte);

module.exports = router;