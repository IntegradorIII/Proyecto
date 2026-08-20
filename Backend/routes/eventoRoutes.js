const express = require('express');
const router = express.Router();
const { verificarToken, soloOperador } = require('../middleware/auth');
const { crearEvento, listarEventos, editarEvento, eliminarEvento, misEventos } = require('../controllers/eventoController');
const { asociarParticipante, listarParticipantes } = require('../controllers/participanteController');

router.post('/', verificarToken, soloOperador, crearEvento);
router.get('/', verificarToken, listarEventos);
router.get('/mis-eventos', verificarToken, misEventos);
router.put('/:id', verificarToken, soloOperador, editarEvento);
router.delete('/:id', verificarToken, soloOperador, eliminarEvento);
router.post('/:id/participantes', verificarToken, soloOperador, asociarParticipante);
router.get('/:id/participantes', verificarToken, listarParticipantes);

module.exports = router;