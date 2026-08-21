const bcrypt = require('bcryptjs');
const { Op } = require('sequelize');
const Usuario = require('../models/Usuario');

const ROLES_PERMITIDOS = ['Administrador', 'Operador', 'Miembro', 'Invitado'];
const EMAIL_REGEX = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;

const registrarUsuario = async (req, res) => {
  try {
    const { nombre, cedula, correo, password, rol } = req.body;

    if (!nombre || !cedula || !correo || !password || !rol) {
      return res.status(400).json({ mensaje: 'Todos los campos son obligatorios' });
    }

    if (typeof password !== 'string' || password.trim().length < 5) {
      return res.status(400).json({ mensaje: 'La contraseña debe tener al menos 5 caracteres' });
    }

    if (!EMAIL_REGEX.test(correo)) {
      return res.status(400).json({ mensaje: 'El formato del correo electrónico no es válido' });
    }

    if (!ROLES_PERMITIDOS.includes(rol)) {
      return res.status(400).json({
        mensaje: `Rol inválido. Los roles permitidos son: ${ROLES_PERMITIDOS.join(', ')}`,
      });
    }

    const existeCorreo = await Usuario.findOne({ where: { correo } });
    if (existeCorreo) {
      return res.status(400).json({ mensaje: 'Ya existe un usuario con ese correo' });
    }

    const existeCedula = await Usuario.findOne({ where: { cedula } });
    if (existeCedula) {
      return res.status(400).json({ mensaje: 'Ya existe un usuario con esa cédula' });
    }

    const passwordHash = await bcrypt.hash(password.trim(), 10);

    const nuevoUsuario = await Usuario.create({
      nombre: nombre.trim(),
      cedula: cedula.trim(),
      correo: correo.trim().toLowerCase(),
      passwordHash,
      rol,
    });

    res.status(201).json({
      mensaje: 'Usuario registrado correctamente',
      usuario: {
        id: nuevoUsuario.id,
        nombre: nuevoUsuario.nombre,
        cedula: nuevoUsuario.cedula,
        correo: nuevoUsuario.correo,
        rol: nuevoUsuario.rol,
      },
    });
  } catch (error) {
    console.error('Error en registrarUsuario:', error);
    res.status(500).json({ mensaje: 'Error interno del servidor al registrar usuario' });
  }
};

const listarUsuarios = async (req, res) => {
  try {
    const usuarios = await Usuario.findAll({
      attributes: ['id', 'nombre', 'cedula', 'correo', 'rol', 'createdAt'],
      order: [['id', 'ASC']],
    });
    res.json({ usuarios });
  } catch (error) {
    console.error('Error en listarUsuarios:', error);
    res.status(500).json({ mensaje: 'Error interno del servidor al listar usuarios' });
  }
};

const editarUsuario = async (req, res) => {
  try {
    const { id } = req.params;
    const { nombre, cedula, correo, password, rol } = req.body;

    const usuario = await Usuario.findByPk(id);
    if (!usuario) {
      return res.status(404).json({ mensaje: 'Usuario no encontrado' });
    }

    const camposAActualizar = {};

    if (nombre !== undefined) {
      if (!nombre.trim()) {
        return res.status(400).json({ mensaje: 'El nombre no puede estar vacío' });
      }
      camposAActualizar.nombre = nombre.trim();
    }

    if (cedula !== undefined) {
      if (!cedula.trim()) {
        return res.status(400).json({ mensaje: 'La cédula no puede estar vacía' });
      }
      const existeCedula = await Usuario.findOne({
        where: { cedula: cedula.trim(), id: { [Op.ne]: id } },
      });
      if (existeCedula) {
        return res.status(400).json({ mensaje: 'Ya existe otro usuario con esa cédula' });
      }
      camposAActualizar.cedula = cedula.trim();
    }

    if (correo !== undefined) {
      const correoNormalizado = correo.trim().toLowerCase();
      if (!EMAIL_REGEX.test(correoNormalizado)) {
        return res.status(400).json({ mensaje: 'El formato del correo electrónico no es válido' });
      }
      const existeCorreo = await Usuario.findOne({
        where: { correo: correoNormalizado, id: { [Op.ne]: id } },
      });
      if (existeCorreo) {
        return res.status(400).json({ mensaje: 'Ya existe otro usuario con ese correo' });
      }
      camposAActualizar.correo = correoNormalizado;
    }

    if (rol !== undefined) {
      if (!ROLES_PERMITIDOS.includes(rol)) {
        return res.status(400).json({
          mensaje: `Rol inválido. Los roles permitidos son: ${ROLES_PERMITIDOS.join(', ')}`,
        });
      }
      camposAActualizar.rol = rol;
    }

    if (password !== undefined && password !== '') {
      if (typeof password !== 'string' || password.trim().length < 5) {
        return res.status(400).json({ mensaje: 'La contraseña debe tener al menos 5 caracteres' });
      }
      camposAActualizar.passwordHash = await bcrypt.hash(password.trim(), 10);
    }

    await usuario.update(camposAActualizar);

    res.json({
      mensaje: 'Usuario actualizado correctamente',
      usuario: {
        id: usuario.id,
        nombre: usuario.nombre,
        cedula: usuario.cedula,
        correo: usuario.correo,
        rol: usuario.rol,
      },
    });
  } catch (error) {
    console.error('Error en editarUsuario:', error);
    res.status(500).json({ mensaje: 'Error interno del servidor al editar usuario' });
  }
};

const eliminarUsuario = async (req, res) => {
  try {
    const { id } = req.params;

    if (req.usuario && req.usuario.id === parseInt(id, 10)) {
      return res.status(400).json({ mensaje: 'No puede eliminar su propia cuenta de usuario' });
    }

    const usuario = await Usuario.findByPk(id);
    if (!usuario) {
      return res.status(404).json({ mensaje: 'Usuario no encontrado' });
    }

    await usuario.destroy();
    res.json({ mensaje: 'Usuario eliminado correctamente' });
  } catch (error) {
    console.error('Error en eliminarUsuario:', error);
    res.status(500).json({ mensaje: 'Error interno del servidor al eliminar usuario' });
  }
};

module.exports = { registrarUsuario, listarUsuarios, editarUsuario, eliminarUsuario };