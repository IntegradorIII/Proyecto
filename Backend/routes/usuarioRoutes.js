const express = require('express');
const router = express.Router();
const { verificarToken, soloAdmin } = require('../middleware/auth');
const { registrarUsuario, listarUsuarios, editarUsuario, eliminarUsuario } = require('../controllers/usuarioController');

router.post('/', verificarToken, soloAdmin, registrarUsuario);
router.get('/', verificarToken, soloAdmin, listarUsuarios);
router.put('/:id', verificarToken, soloAdmin, editarUsuario);
router.delete('/:id', verificarToken, soloAdmin, eliminarUsuario);

module.exports = router;