const express = require('express');
const router = express.Router();
const { registrarAsistencia } = require('../controllers/asistenciaController');
const { verificarToken } = require('../middlewares/authMiddleware');

// Proteger todas las rutas de asistencia para que requieran token válido
router.use(verificarToken);

// Ruta para hacer Check-in (Aplicando RN-04 y RN-05)
router.post('/check-in', registrarAsistencia);

module.exports = router;
