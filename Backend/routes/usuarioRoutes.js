const express = require('express');
const router = express.Router();
const { listarUsuarios, editarUsuario, eliminarUsuario } = require('../controllers/usuarioController');

router.get('/', listarUsuarios);
router.put('/:id', editarUsuario);
router.delete('/:id', eliminarUsuario);

module.exports = router;