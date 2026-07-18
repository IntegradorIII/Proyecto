const Evento = require('../models/Evento');

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

module.exports = { crearEvento, listarEventos };