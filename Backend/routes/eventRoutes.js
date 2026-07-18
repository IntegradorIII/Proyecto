const express = require('express');
const router = express.Router();
const { crearEvento, editarEvento, eliminarEvento, registrarAsistenciaManual } = require('../controllers/eventController');
const { verificarToken, checkRole } = require('../middlewares/authMiddleware');

// Validar token en todas las rutas de eventos
router.use(verificarToken); 

// RN-09: Mecanismo de Respaldo Manual
// Protegido para que solo Operadores y Administradores puedan registrar asistencias manuales
router.post('/:id/asistencia-manual/:usuarioId', checkRole(['Operador', 'Administrador']), registrarAsistenciaManual);

// RN-01: Exclusividad en Creación de Eventos
// Solo los usuarios autenticados con el rol de Administrador pueden crear, editar o eliminar un evento.
router.post('/', checkRole(['Administrador']), crearEvento);
router.put('/:id', checkRole(['Administrador']), editarEvento);
router.delete('/:id', checkRole(['Administrador']), eliminarEvento);

module.exports = router;
