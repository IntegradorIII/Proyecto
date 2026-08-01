const express = require('express');
const router = express.Router();
const { crearEvento, listarEventos, editarEvento, eliminarEvento } = require('../controllers/eventoController');
const { asociarParticipante, listarParticipantes } = require('../controllers/participanteController');

router.post('/', crearEvento);
router.get('/', listarEventos);
router.put('/:id', editarEvento);
router.delete('/:id', eliminarEvento);
router.post('/:id/participantes', asociarParticipante);
router.get('/:id/participantes', listarParticipantes);

module.exports = router;