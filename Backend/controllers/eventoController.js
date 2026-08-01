const Evento = require('../models/Evento');
const Asistencia = require('../models/Asistencia');
const Participante = require('../models/Participante');

const crearEvento = async (req, res) => {
  try {
    const { nombre, fecha, hora, lugar, toleranciaMin } = req.body;

    if (!nombre || !fecha || !hora || !lugar) {
      return res.status(400).json({ mensaje: 'Todos los campos son obligatorios' });
    }

    const nuevoEvento = await Evento.create({
      nombre,
      fecha,
      hora,
      lugar,
      toleranciaMin: toleranciaMin || 20,
    });

    res.status(201).json({
      mensaje: 'Evento creado correctamente',
      evento: nuevoEvento,
    });
  } catch (error) {
    console.error('Error en crearEvento:', error);
    res.status(500).json({ mensaje: 'Error al crear evento', error: error.message });
  }
};

const listarEventos = async (req, res) => {
  try {
    const eventos = await Evento.findAll({
      order: [['fecha', 'ASC']],
    });
    res.json({ eventos });
  } catch (error) {
    console.error('Error en listarEventos:', error);
    res.status(500).json({ mensaje: 'Error al obtener eventos', error: error.message });
  }
};
const editarEvento = async (req, res) => {
  try {
    const { id } = req.params;
    const { nombre, fecha, hora, lugar, toleranciaMin } = req.body;

    const evento = await Evento.findByPk(id);
    if (!evento) {
      return res.status(404).json({ mensaje: 'Evento no encontrado' });
    }

    const tieneAsistencias = await Asistencia.findOne({
      include: [{
        model: Participante,
        where: { eventoId: id },
      }],
    });
    if (tieneAsistencias) {
      return res.status(400).json({ mensaje: 'No se puede editar un evento que ya tiene asistencias registradas' });
    }

    await evento.update({ nombre, fecha, hora, lugar, toleranciaMin });

    res.json({ mensaje: 'Evento actualizado correctamente', evento });
  } catch (error) {
    console.error('Error en editarEvento:', error);
    res.status(500).json({ mensaje: 'Error al editar evento', error: error.message });
  }
};

const eliminarEvento = async (req, res) => {
  try {
    const { id } = req.params;

    const evento = await Evento.findByPk(id);
    if (!evento) {
      return res.status(404).json({ mensaje: 'Evento no encontrado' });
    }

    const tieneAsistencias = await Asistencia.findOne({
      include: [{
        model: Participante,
        where: { eventoId: id },
      }],
    });
    if (tieneAsistencias) {
      return res.status(400).json({ mensaje: 'No se puede eliminar un evento que ya tiene asistencias registradas' });
    }

    await evento.destroy();
    res.json({ mensaje: 'Evento eliminado correctamente' });
  } catch (error) {
    console.error('Error en eliminarEvento:', error);
    res.status(500).json({ mensaje: 'Error al eliminar evento', error: error.message });
  }
};

module.exports = { crearEvento, listarEventos, editarEvento, eliminarEvento };