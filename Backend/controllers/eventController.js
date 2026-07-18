const { Evento, Asistencia, Participante } = require('../models');

// RN-03: Prevención de Eventos Duplicados
const crearEvento = async (req, res) => {
  try {
    const { titulo, descripcion, fecha, horaInicio, lugar } = req.body;

    // Verificar si ya existe un evento en la misma fecha, hora y lugar
    const eventoDuplicado = await Evento.findOne({
      where: {
        fecha,
        horaInicio,
        lugar
      }
    });

    if (eventoDuplicado) {
      return res.status(400).json({ 
        mensaje: 'Restricción de Negocio (RN-03): Ya existe un evento programado en esa misma fecha, hora y lugar.' 
      });
    }

    const nuevoEvento = await Evento.create({
      titulo,
      descripcion,
      fecha,
      horaInicio,
      lugar,
      creadorId: req.usuario.id // Asignado desde el token JWT en el middleware
    });

    res.status(201).json({ mensaje: 'Evento creado exitosamente', evento: nuevoEvento });
  } catch (error) {
    console.error('Error al crear evento:', error);
    res.status(500).json({ mensaje: 'Error interno al crear el evento', error: error.message });
  }
};

// RN-02: Restricción de Modificación Post-Ejecución (Edición)
const editarEvento = async (req, res) => {
  try {
    const { id } = req.params;
    const { titulo, descripcion, fecha, horaInicio, lugar } = req.body;

    const evento = await Evento.findByPk(id);
    if (!evento) {
      return res.status(404).json({ mensaje: 'Evento no encontrado' });
    }

    // Verificar si el evento ya cuenta con registros de asistencia
    const asistenciasCount = await Asistencia.count({ where: { eventoId: id } });
    if (asistenciasCount > 0) {
      return res.status(400).json({ 
        mensaje: 'Restricción de Negocio (RN-02): No se puede editar un evento que ya cuenta con registros de asistencia.' 
      });
    }

    await evento.update({ titulo, descripcion, fecha, horaInicio, lugar });

    res.status(200).json({ mensaje: 'Evento actualizado correctamente', evento });
  } catch (error) {
    console.error('Error al editar evento:', error);
    res.status(500).json({ mensaje: 'Error interno al editar el evento', error: error.message });
  }
};

// RN-02: Restricción de Modificación Post-Ejecución (Eliminación)
const eliminarEvento = async (req, res) => {
  try {
    const { id } = req.params;

    const evento = await Evento.findByPk(id);
    if (!evento) {
      return res.status(404).json({ mensaje: 'Evento no encontrado' });
    }

    // Verificar si el evento ya cuenta con registros de asistencia
    const asistenciasCount = await Asistencia.count({ where: { eventoId: id } });
    if (asistenciasCount > 0) {
      return res.status(400).json({ 
        mensaje: 'Restricción de Negocio (RN-02): No se puede eliminar un evento que ya cuenta con registros de asistencia.' 
      });
    }

    await evento.destroy();

    res.status(200).json({ mensaje: 'Evento eliminado correctamente' });
  } catch (error) {
    console.error('Error al eliminar evento:', error);
    res.status(500).json({ mensaje: 'Error interno al eliminar el evento', error: error.message });
  }
};

// RN-09: Mecanismo de Respaldo Manual
const registrarAsistenciaManual = async (req, res) => {
  try {
    const { id: eventoId, usuarioId } = req.params;
    let { estado } = req.body;

    // Normalizar 'Tardío' a 'Tardanza' según el ENUM del modelo
    if (estado === 'Tardío') estado = 'Tardanza';

    if (!['Presente', 'Tardanza'].includes(estado)) {
      return res.status(400).json({ mensaje: "El estado debe ser 'Presente' o 'Tardanza'" });
    }

    const evento = await Evento.findByPk(eventoId);
    if (!evento) {
      return res.status(404).json({ mensaje: 'Evento no encontrado' });
    }

    // Validar que el participante esté convocado
    const participante = await Participante.findOne({
      where: {
        eventoId,
        usuarioId
      }
    });

    if (!participante) {
      return res.status(400).json({ mensaje: 'El usuario no está convocado a este evento' });
    }

    // RN-05: Evitar duplicidad de asistencia
    const asistenciaPrevia = await Asistencia.findOne({
      where: {
        eventoId,
        usuarioId
      }
    });

    if (asistenciaPrevia) {
      return res.status(400).json({ mensaje: 'El participante ya tiene un registro de asistencia en este evento' });
    }

    const nuevaAsistencia = await Asistencia.create({
      eventoId,
      usuarioId,
      estado,
      tipo_registro: 'Manual',
      registrado_por: req.usuario.id // Extraído del token
    });

    res.status(201).json({
      mensaje: 'Asistencia manual registrada exitosamente',
      asistencia: nuevaAsistencia
    });
  } catch (error) {
    console.error('Error al registrar asistencia manual:', error);
    res.status(500).json({ mensaje: 'Error interno al registrar asistencia manual', error: error.message });
  }
};

module.exports = { crearEvento, editarEvento, eliminarEvento, registrarAsistenciaManual };
