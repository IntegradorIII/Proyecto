const Participante = require('../models/Participante');
const Usuario = require('../models/Usuario');
const Evento = require('../models/Evento');
const QRCode = require('qrcode');

const registrarParticipante = async (req, res) => {
  try {
    const { nombre, cedula, correo, rol } = req.body;

    if (!nombre || !cedula || !correo || !rol) {
      return res.status(400).json({ mensaje: 'Todos los campos son obligatorios' });
    }

    const existe = await Usuario.findOne({ where: { cedula } });
    if (existe) {
      return res.status(400).json({ mensaje: 'Ya existe un usuario con esa cédula' });
    }

    const nuevoUsuario = await Usuario.create({
      nombre,
      cedula,
      correo,
      passwordHash: '-',
      rol,
    });

    res.status(201).json({
      mensaje: 'Participante registrado correctamente',
      participante: {
        id: nuevoUsuario.id,
        nombre: nuevoUsuario.nombre,
        cedula: nuevoUsuario.cedula,
        correo: nuevoUsuario.correo,
        rol: nuevoUsuario.rol,
      },
    });
  } catch (error) {
    console.error('Error en registrarParticipante:', error);
    res.status(500).json({ mensaje: 'Error al registrar participante', error: error.message });
  }
};

const asociarParticipante = async (req, res) => {
  try {
    const { id } = req.params;
    const { usuarioId } = req.body;

    const evento = await Evento.findByPk(id);
    if (!evento) {
      return res.status(404).json({ mensaje: 'Evento no encontrado' });
    }

    const usuario = await Usuario.findByPk(usuarioId);
    if (!usuario) {
      return res.status(404).json({ mensaje: 'Usuario no encontrado' });
    }

    const yaAsociado = await Participante.findOne({
      where: { eventoId: id, usuarioId },
    });
    if (yaAsociado) {
      return res.status(400).json({ mensaje: 'El participante ya está asociado a este evento' });
    }

    const participante = await Participante.create({
      eventoId: id,
      usuarioId,
    });

    res.status(201).json({
      mensaje: 'Participante asociado correctamente al evento',
      participante,
    });
  } catch (error) {
    console.error('Error en asociarParticipante:', error);
    res.status(500).json({ mensaje: 'Error al asociar participante', error: error.message });
  }
};

const listarParticipantes = async (req, res) => {
  try {
    const { id } = req.params;

    const evento = await Evento.findByPk(id);
    if (!evento) {
      return res.status(404).json({ mensaje: 'Evento no encontrado' });
    }

    const participantes = await Participante.findAll({
      where: { eventoId: id },
      include: [{ model: Usuario, attributes: ['id', 'nombre', 'cedula', 'correo', 'rol'] }],
    });

    res.json({ evento: evento.nombre, participantes });
  } catch (error) {
    console.error('Error en listarParticipantes:', error);
    res.status(500).json({ mensaje: 'Error al listar participantes', error: error.message });
  }
};

module.exports = { asociarParticipante, listarParticipantes };