const express = require('express');
const router = express.Router();
const { crearEvento, editarEvento, eliminarEvento } = require('../controllers/eventController');
const { verificarToken, checkRole } = require('../middlewares/authMiddleware');

// RN-01: Exclusividad en Creación de Eventos
// Solo los usuarios autenticados con el rol de Administrador pueden crear, editar o eliminar un evento.
router.use(verificarToken); // Aplica a todas las rutas de este router
router.use(checkRole(['Administrador'])); // Exige rol Administrador a todas las rutas

router.post('/', crearEvento);
router.put('/:id', editarEvento);
router.delete('/:id', eliminarEvento);

module.exports = router;
