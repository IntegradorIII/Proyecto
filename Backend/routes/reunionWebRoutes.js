const express = require('express');
const router = express.Router();
const {
  verReunion,
  verLoginReunion,
  verInvitadoReunion,
} = require('../controllers/reunionWebController');

// Ruta principal al escanear QR base: /reunion/:id
router.get('/reunion/:id', verReunion);

// Ruta directa para miembros: /reunion/:id/login
router.get('/reunion/:id/login', verLoginReunion);

// Ruta directa para invitados: /reunion/:id/invitado
router.get('/reunion/:id/invitado', verInvitadoReunion);

// Rutas auxiliares con query param ?reunionId=...
router.get('/login', verLoginReunion);
router.get('/invitado', verInvitadoReunion);

module.exports = router;
