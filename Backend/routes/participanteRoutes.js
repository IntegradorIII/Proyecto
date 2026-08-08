const express = require('express');
const router = express.Router();
const { verificarToken, soloOperador } = require('../middleware/auth');
const {
  asociarParticipante,
  listarParticipantes,
} = require('../controllers/participanteController');

router.post('/:id/participantes', verificarToken, soloOperador, asociarParticipante);
router.get('/:id/participantes', verificarToken, listarParticipantes);

module.exports = router;