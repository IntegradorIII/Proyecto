const { Asistencia, Participante, Evento, Usuario } = require('../models');

// Función para registrar asistencia (Check-In)
const registrarAsistencia = async (req, res) => {
  try {
    const { eventoId, usuarioId } = req.body;

    // Validación básica
    if (!eventoId || !usuarioId) {
      return res.status(400).json({ mensaje: 'Faltan datos obligatorios: eventoId y usuarioId.' });
    }

    // Comprobar si el evento y el usuario existen
    const evento = await Evento.findByPk(eventoId);
    if (!evento) {
      return res.status(404).json({ mensaje: 'Evento no encontrado.' });
    }
    const usuario = await Usuario.findByPk(usuarioId);
    if (!usuario) {
      return res.status(404).json({ mensaje: 'Usuario no encontrado.' });
    }

    // RN-04: Delimitación de Convocatoria Obligatoria
    // Verificar si el usuario fue convocado como participante del evento
    const esParticipante = await Participante.findOne({
      where: {
        eventoId,
        usuarioId
      }
    });

    if (!esParticipante) {
      return res.status(403).json({ 
        mensaje: 'Restricción de Negocio (RN-04): El usuario no está en la lista de convocados para este evento.' 
      });
    }

    // RN-05: Unicidad del Registro de Asistencia
    // Verificar si ya existe un registro previo de asistencia
    const asistenciaPrevia = await Asistencia.findOne({
      where: {
        eventoId,
        usuarioId
      }
    });

    if (asistenciaPrevia) {
      return res.status(409).json({ 
        mensaje: 'Restricción de Negocio (RN-05): La asistencia de este participante ya fue registrada.' 
      });
    }

    // Si pasa todas las validaciones, procedemos a registrar la asistencia
    const nuevaAsistencia = await Asistencia.create({
      eventoId,
      usuarioId,
      estado: 'Presente' // Por defecto Presente al momento de escanear/hacer check-in
    });

    return res.status(201).json({
      mensaje: 'Asistencia registrada correctamente.',
      asistencia: nuevaAsistencia
    });

  } catch (error) {
    console.error('Error al registrar asistencia:', error);
    res.status(500).json({ mensaje: 'Error interno al registrar la asistencia', error: error.message });
  }
};

module.exports = {
  registrarAsistencia
};
