const express = require('express');
const router = express.Router();
const { crearEvento, listarEventos } = require('../controllers/eventoController');
const { asociarParticipante, listarParticipantes } = require('../controllers/participanteController');

router.post('/', crearEvento);
router.get('/', listarEventos);
router.post('/:id/participantes', asociarParticipante);
router.get('/:id/participantes', listarParticipantes);

module.exports = router;