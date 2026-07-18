const express = require('express');
const router = express.Router();
const { crearEvento, listarEventos } = require('../controllers/eventoController');

router.post('/', crearEvento);
router.get('/', listarEventos);

module.exports = router;