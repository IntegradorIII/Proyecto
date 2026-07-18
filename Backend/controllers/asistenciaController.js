const { Asistencia, Participante, Evento, Usuario } = require('../models');

// Función para registrar asistencia (Check-In)
const registrarAsistencia = async (req, res) => {
  try {
    const { eventoId, usuarioId, esInvitado, invitadoNombre, invitadoCedula } = req.body;

    if (!eventoId) {
      return res.status(400).json({ mensaje: 'Faltan datos obligatorios: eventoId.' });
    }

    const evento = await Evento.findByPk(eventoId);
    if (!evento) {
      return res.status(404).json({ mensaje: 'Evento no encontrado.' });
    }

    // RN-08: Bifurcación del Flujo Invitado vs Miembro
    if (esInvitado) {
      if (!invitadoNombre || !invitadoCedula) {
        return res.status(400).json({ mensaje: 'Para invitados, nombre completo y cédula son obligatorios.' });
      }

      const nuevaAsistencia = await Asistencia.create({
        eventoId,
        estado: 'Invitado',
        esInvitado: true,
        invitadoNombre,
        invitadoCedula
      });

      return res.status(201).json({
        mensaje: 'Asistencia de invitado registrada correctamente.',
        asistencia: nuevaAsistencia
      });
    }

    // Flujo Miembro
    if (!usuarioId) {
      return res.status(400).json({ mensaje: 'Faltan datos obligatorios: usuarioId.' });
    }

    const usuario = await Usuario.findByPk(usuarioId);
    if (!usuario) {
      return res.status(404).json({ mensaje: 'Usuario no encontrado.' });
    }

    // RN-04: Delimitación de Convocatoria Obligatoria
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

    // RN-06: Gestión de Tolerancia Luminal (Cálculo de Tardanza)
    // Combinar evento.fecha y evento.horaInicio
    const fechaHoraEventoStr = `${evento.fecha}T${evento.horaInicio}`;
    const inicioEvento = new Date(fechaHoraEventoStr);
    const ahora = new Date();

    let estadoCalculado = 'Presente';
    // Validar si la fecha del evento es válida
    if (!isNaN(inicioEvento.getTime())) {
      const diffMs = ahora - inicioEvento;
      const diffMinutos = Math.floor(diffMs / (1000 * 60));
      
      // Tolerancia de 20 minutos
      if (diffMinutos > 20) {
        estadoCalculado = 'Tardanza';
      }
    }

    // Procedemos a registrar la asistencia
    const nuevaAsistencia = await Asistencia.create({
      eventoId,
      usuarioId,
      estado: estadoCalculado
    });

    return res.status(201).json({
      mensaje: 'Asistencia registrada correctamente.',
      estadoAsignado: estadoCalculado,
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
