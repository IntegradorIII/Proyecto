const express = require('express');
const router = express.Router();
const {
  registrarParticipante,
  asociarParticipante,
  listarParticipantes,
} = require('../controllers/participanteController');

router.post('/', registrarParticipante);
router.post('/:id/participantes', asociarParticipante);
router.get('/:id/participantes', listarParticipantes);

module.exports = router;