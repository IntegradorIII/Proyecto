const rateLimit = require('express-rate-limit');

// Límite para intentos de inicio de sesión: 10 intentos cada 15 minutos por IP
const loginLimiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  max: 10,
  message: {
    mensaje: 'Demasiados intentos de inicio de sesión. Por favor intente nuevamente en 15 minutos.',
  },
  standardHeaders: true,
  legacyHeaders: false,
});

// Límite para registros de check-in: 30 peticiones por minuto por IP
const checkInLimiter = rateLimit({
  windowMs: 1 * 60 * 1000,
  max: 30,
  message: {
    mensaje: 'Demasiadas solicitudes de check-in. Por favor intente de nuevo en un momento.',
  },
  standardHeaders: true,
  legacyHeaders: false,
});

module.exports = { loginLimiter, checkInLimiter };
