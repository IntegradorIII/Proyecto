const Asistencia = require('../models/Asistencia');
const Participante = require('../models/Participante');
const Evento = require('../models/Evento');
const Usuario = require('../models/Usuario');

const checkInQR = async (req, res) => {
  try {
    const { participanteId, eventoId } = req.body;

    const participante = await Participante.findOne({
      where: { id: participanteId, eventoId },
    });
    if (!participante) {
      return res.status(404).json({ mensaje: 'Participante no encontrado en este evento' });
    }

    const yaRegistrado = await Asistencia.findOne({ where: { participanteId } });
    if (yaRegistrado) {
      return res.status(409).json({ mensaje: 'El participante ya tiene asistencia registrada' });
    }

    const evento = await Evento.findByPk(eventoId);
    const ahora = new Date();
    const horaEvento = new Date(ahora.toDateString() + ' ' + evento.hora);
    const diffMinutos = (ahora - horaEvento) / (1000 * 60);
    const estado = diffMinutos <= evento.toleranciaMin ? 'presente' : 'tardio';

    const asistencia = await Asistencia.create({
      participanteId,
      horaIngreso: ahora,
      metodo: 'qr',
      estado,
    });

    res.json({
      mensaje: `Asistencia registrada como ${estado}`,
      asistencia,
    });
  } catch (error) {
    console.error('Error en checkInQR:', error);
    res.status(500).json({ mensaje: 'Error al registrar asistencia', error: error.message });
  }
};

const checkInManual = async (req, res) => {
  try {
    const { id } = req.params;
    const { participanteId } = req.body;

    const participante = await Participante.findOne({
      where: { id: participanteId, eventoId: id },
    });
    if (!participante) {
      return res.status(404).json({ mensaje: 'Participante no encontrado en este evento' });
    }

    const yaRegistrado = await Asistencia.findOne({ where: { participanteId } });
    if (yaRegistrado) {
      return res.status(409).json({ mensaje: 'El participante ya tiene asistencia registrada' });
    }

    const evento = await Evento.findByPk(id);
    const ahora = new Date();
    const horaEvento = new Date(ahora.toDateString() + ' ' + evento.hora);
    const diffMinutos = (ahora - horaEvento) / (1000 * 60);
    const estado = diffMinutos <= evento.toleranciaMin ? 'presente' : 'tardio';

    const asistencia = await Asistencia.create({
      participanteId,
      horaIngreso: ahora,
      metodo: 'manual',
      estado,
    });

    res.json({
      mensaje: `Asistencia manual registrada como ${estado}`,
      asistencia,
    });
  } catch (error) {
    console.error('Error en checkInManual:', error);
    res.status(500).json({ mensaje: 'Error al registrar asistencia manual', error: error.message });
  }
};

const reporte = async (req, res) => {
  try {
    const { id } = req.params;

    const evento = await Evento.findByPk(id);
    if (!evento) {
      return res.status(404).json({ mensaje: 'Evento no encontrado' });
    }

    const participantes = await Participante.findAll({
      where: { eventoId: id },
      include: [
        { model: Usuario, attributes: ['nombre', 'cedula', 'correo', 'rol'] },
        { model: Asistencia, attributes: ['horaIngreso', 'metodo', 'estado'], required: false },
      ],
    });

    const reporte = participantes.map(p => ({
      nombre: p.Usuario.nombre,
      cedula: p.Usuario.cedula,
      correo: p.Usuario.correo,
      estado: p.Asistencia ? p.Asistencia.estado : 'ausente',
      metodo: p.Asistencia ? p.Asistencia.metodo : null,
      horaIngreso: p.Asistencia ? p.Asistencia.horaIngreso : null,
    }));

    res.json({
      evento: evento.nombre,
      fecha: evento.fecha,
      total: reporte.length,
      presentes: reporte.filter(p => p.estado === 'presente').length,
      tardios: reporte.filter(p => p.estado === 'tardio').length,
      ausentes: reporte.filter(p => p.estado === 'ausente').length,
      detalle: reporte,
    });
  } catch (error) {
    console.error('Error en reporte:', error);
    res.status(500).json({ mensaje: 'Error al generar reporte', error: error.message });
  }
};

module.exports = { checkInQR, checkInManual, reporte };