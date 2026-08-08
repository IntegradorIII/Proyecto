const bcrypt = require('bcryptjs');
const Usuario = require('../models/Usuario');

const registrarUsuario = async (req, res) => {
  try {
    const { nombre, cedula, correo, password, rol } = req.body;

    if (!nombre || !cedula || !correo || !password || !rol) {
      return res.status(400).json({ mensaje: 'Todos los campos son obligatorios' });
    }

    const existe = await Usuario.findOne({ where: { correo } });
    if (existe) {
      return res.status(400).json({ mensaje: 'Ya existe un usuario con ese correo' });
    }

    const passwordHash = await bcrypt.hash(password, 10);

    const nuevoUsuario = await Usuario.create({
      nombre,
      cedula,
      correo,
      passwordHash,
      rol,
    });

    res.status(201).json({
      mensaje: 'Usuario registrado correctamente',
      usuario: {
        id: nuevoUsuario.id,
        nombre: nuevoUsuario.nombre,
        correo: nuevoUsuario.correo,
        rol: nuevoUsuario.rol,
      },
    });
  } catch (error) {
    console.error('Error en registrarUsuario:', error);
    res.status(500).json({ mensaje: 'Error al registrar usuario', error: error.message });
  }
};

const listarUsuarios = async (req, res) => {
  try {
    const usuarios = await Usuario.findAll({
      attributes: ['id', 'nombre', 'cedula', 'correo', 'rol'],
    });
    res.json({ usuarios });
  } catch (error) {
    console.error('Error en listarUsuarios:', error);
    res.status(500).json({ mensaje: 'Error al listar usuarios', error: error.message });
  }
};

const editarUsuario = async (req, res) => {
  try {
    const { id } = req.params;
    const { nombre, cedula, correo, rol } = req.body;

    const usuario = await Usuario.findByPk(id);
    if (!usuario) {
      return res.status(404).json({ mensaje: 'Usuario no encontrado' });
    }

    await usuario.update({ nombre, cedula, correo, rol });
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
    res.status(500).json({ mensaje: 'Error al editar usuario', error: error.message });
  }
};

const eliminarUsuario = async (req, res) => {
  try {
    const { id } = req.params;

    const usuario = await Usuario.findByPk(id);
    if (!usuario) {
      return res.status(404).json({ mensaje: 'Usuario no encontrado' });
    }

    await usuario.destroy();
    res.json({ mensaje: 'Usuario eliminado correctamente' });
  } catch (error) {
    console.error('Error en eliminarUsuario:', error);
    res.status(500).json({ mensaje: 'Error al eliminar usuario', error: error.message });
  }
};

module.exports = { registrarUsuario, listarUsuarios, editarUsuario, eliminarUsuario };