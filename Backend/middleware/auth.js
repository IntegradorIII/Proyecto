const jwt = require('jsonwebtoken');

const verificarToken = (req, res, next) => {
  const authHeader = req.headers['authorization'];
  const token = authHeader && authHeader.split(' ')[1];

  if (!token) {
    return res.status(401).json({ mensaje: 'Acceso denegado. Token no proporcionado.' });
  }

  try {
    const decoded = jwt.verify(token, process.env.JWT_SECRET);
    req.usuario = decoded;
    next();
  } catch (error) {
    return res.status(401).json({ mensaje: 'Token inválido o expirado.' });
  }
};

const soloAdmin = (req, res, next) => {
  if (req.usuario.rol !== 'Administrador') {
    return res.status(403).json({ mensaje: 'Acceso denegado. Se requiere rol Administrador.' });
  }
  next();
};

const soloOperador = (req, res, next) => {
  if (req.usuario.rol !== 'Operador' && req.usuario.rol !== 'Administrador') {
    return res.status(403).json({ mensaje: 'Acceso denegado. Se requiere rol Operador o Administrador.' });
  }
  next();
};

module.exports = { verificarToken, soloAdmin, soloOperador };