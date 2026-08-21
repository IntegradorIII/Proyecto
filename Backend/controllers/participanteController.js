const Participante = require('../models/Participante');
const Usuario = require('../models/Usuario');
const Evento = require('../models/Evento');

const asociarParticipante = async (req, res) => {
  try {
    const { id } = req.params;
    const { usuarioId } = req.body;

    if (!usuarioId) {
      return res.status(400).json({ mensaje: 'El usuarioId es obligatorio' });
    }

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
    res.status(500).json({ mensaje: 'Error interno del servidor al asociar participante' });
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
    res.status(500).json({ mensaje: 'Error interno del servidor al listar participantes' });
  }
};

module.exports = { asociarParticipante, listarParticipantes };