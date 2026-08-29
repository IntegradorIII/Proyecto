const Evento = require('../models/Evento');
const Asistencia = require('../models/Asistencia');
const Participante = require('../models/Participante');
const QRCode = require('qrcode');

const construirFechaHora = (fecha, hora) => {
  if (!fecha || !hora) return null;
  const [year, month, day] = fecha.split('-').map(Number);
  const [hours, minutes, seconds = 0] = hora.split(':').map(Number);
  return new Date(year, month - 1, day, hours, minutes, seconds);
};

const crearEvento = async (req, res) => {
  try {
    const { nombre, fecha, hora, lugar, toleranciaMin, tipoReunion } = req.body;

    if (!nombre || !fecha || !hora || !lugar) {
      return res.status(400).json({ mensaje: 'Todos los campos son obligatorios' });
    }

    const fechaHoraEvento = construirFechaHora(fecha, hora);
    if (!fechaHoraEvento || isNaN(fechaHoraEvento.getTime())) {
      return res.status(400).json({ mensaje: 'Formato de fecha u hora inválido' });
    }

    const ahora = new Date();
    const diffMinutos = (fechaHoraEvento - ahora) / (1000 * 60);
    if (diffMinutos < 30) {
      return res.status(400).json({
        mensaje: 'No se pueden crear eventos en el pasado ni con menos de 30 minutos de anticipación',
      });
    }

    const duplicado = await Evento.findOne({ where: { nombre, fecha, hora } });
    if (duplicado) {
      return res.status(400).json({ mensaje: 'Ya existe una reunión con el mismo nombre, fecha y hora' });
    }

    const nuevoEvento = await Evento.create({
      nombre: nombre.trim(),
      fecha,
      hora,
      lugar: lugar.trim(),
      toleranciaMin: toleranciaMin ? parseInt(toleranciaMin, 10) : 20,
      tipoReunion: tipoReunion || 'solo_miembros',
    });

    const baseUrl = process.env.APP_URL || 'http://localhost:3000';
    const rutaRedireccion = nuevoEvento.tipoReunion === 'solo_miembros'
      ? `${baseUrl}/reunion/${nuevoEvento.id}/login`
      : `${baseUrl}/reunion/${nuevoEvento.id}/invitado`;
    const codigoQr = await QRCode.toDataURL(rutaRedireccion);
    await nuevoEvento.update({ codigoQr });

    res.status(201).json({
      mensaje: 'Evento creado correctamente',
      evento: nuevoEvento,
    });
  } catch (error) {
    console.error('Error en crearEvento:', error);
    res.status(500).json({ mensaje: 'Error interno del servidor al crear evento' });
  }
};

const listarEventos = async (req, res) => {
  try {
    if (req.usuario && req.usuario.rol === 'Miembro') {
      const participaciones = await Participante.findAll({
        where: { usuarioId: req.usuario.id },
        include: [
          {
            model: Evento,
            attributes: ['id', 'nombre', 'fecha', 'hora', 'lugar', 'toleranciaMin', 'tipoReunion'],
          },
        ],
        order: [[Evento, 'fecha', 'ASC']],
      });
      const eventos = participaciones.map(p => p.Evento).filter(Boolean);
      return res.json({ eventos });
    }

    const eventos = await Evento.findAll({
      order: [['fecha', 'ASC']],
    });
    res.json({ eventos });
  } catch (error) {
    console.error('Error en listarEventos:', error);
    res.status(500).json({ mensaje: 'Error interno del servidor al obtener eventos' });
  }
};

const misEventos = async (req, res) => {
  try {
    const usuarioId = req.usuario.id;
    const participaciones = await Participante.findAll({
      where: { usuarioId },
      include: [
        {
          model: Evento,
          attributes: ['id', 'nombre', 'fecha', 'hora', 'lugar', 'toleranciaMin', 'tipoReunion'],
        },
      ],
      order: [[Evento, 'fecha', 'ASC']],
    });
    const eventos = participaciones.map(p => p.Evento).filter(Boolean);
    res.json({ eventos });
  } catch (error) {
    console.error('Error en misEventos:', error);
    res.status(500).json({ mensaje: 'Error interno del servidor al obtener sus eventos' });
  }
};

const obtenerEventoPublico = async (req, res) => {
  try {
    const { id } = req.params;
    const evento = await Evento.findByPk(id, {
      attributes: ['id', 'nombre', 'fecha', 'hora', 'lugar', 'toleranciaMin', 'tipoReunion'],
    });
    if (!evento) {
      return res.status(404).json({ mensaje: 'Evento no encontrado' });
    }
    res.json({ evento });
  } catch (error) {
    console.error('Error en obtenerEventoPublico:', error);
    res.status(500).json({ mensaje: 'Error interno del servidor al obtener información del evento' });
  }
};

const editarEvento = async (req, res) => {
  try {
    const { id } = req.params;
    const { nombre, fecha, hora, lugar, toleranciaMin, tipoReunion } = req.body;

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

    const fechaFinal = fecha || evento.fecha;
    const horaFinal = hora || evento.hora;
    const fechaHoraEvento = construirFechaHora(fechaFinal, horaFinal);
    const ahora = new Date();
    const diffMinutos = (fechaHoraEvento - ahora) / (1000 * 60);

    if (diffMinutos < 30) {
      return res.status(400).json({
        mensaje: 'No se puede reprogramar el evento con menos de 30 minutos de anticipación o en el pasado',
      });
    }

    const tipoFinal = tipoReunion || evento.tipoReunion;
    const baseUrl = process.env.APP_URL || 'http://localhost:3000';
    const rutaRedireccion = tipoFinal === 'solo_miembros'
      ? `${baseUrl}/reunion/${evento.id}/login`
      : `${baseUrl}/reunion/${evento.id}/invitado`;
    const codigoQr = await QRCode.toDataURL(rutaRedireccion);

    await evento.update({
      nombre: nombre !== undefined ? nombre.trim() : evento.nombre,
      fecha: fechaFinal,
      hora: horaFinal,
      lugar: lugar !== undefined ? lugar.trim() : evento.lugar,
      toleranciaMin: toleranciaMin !== undefined ? parseInt(toleranciaMin, 10) : evento.toleranciaMin,
      tipoReunion: tipoFinal,
      codigoQr,
    });

    res.json({ mensaje: 'Evento actualizado correctamente', evento });
  } catch (error) {
    console.error('Error en editarEvento:', error);
    res.status(500).json({ mensaje: 'Error interno del servidor al editar evento' });
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

    
    await Participante.destroy({ where: { eventoId: id } });
    await evento.destroy();

    res.json({ mensaje: 'Evento eliminado correctamente' });
  } catch (error) {
    console.error('Error en eliminarEvento:', error);
    res.status(500).json({ mensaje: 'Error interno del servidor al eliminar evento' });
  }
};

module.exports = {
  crearEvento,
  listarEventos,
  misEventos,
  obtenerEventoPublico,
  editarEvento,
  eliminarEvento,
};
