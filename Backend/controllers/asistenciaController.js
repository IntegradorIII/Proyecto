const Asistencia = require('../models/Asistencia');
const Participante = require('../models/Participante');
const Evento = require('../models/Evento');
const Usuario = require('../models/Usuario');

const construirFechaHora = (fecha, hora) => {
  if (!fecha || !hora) return null;
  const [year, month, day] = fecha.split('-').map(Number);
  const [hours, minutes, seconds = 0] = hora.split(':').map(Number);
  return new Date(year, month - 1, day, hours, minutes, seconds);
};

const calcularEstadoAsistencia = (evento) => {
  const ahora = new Date();
  const fechaHoraEvento = construirFechaHora(evento.fecha, evento.hora);
  if (!fechaHoraEvento || isNaN(fechaHoraEvento.getTime())) {
    return { valido: false, mensaje: 'Fecha u hora del evento no válida' };
  }

  const diffMinutos = (ahora - fechaHoraEvento) / (1000 * 60);

  // Si intenta registrarse con más de 15 minutos de antelación al inicio
  if (diffMinutos < -15) {
    return {
      valido: false,
      mensaje: 'La reunión aún no ha iniciado. El registro se habilita 15 minutos antes de la hora fijada.',
    };
  }

  // Si intenta registrarse después de 4 horas (240 minutos) de iniciada la reunión
  if (diffMinutos > 240) {
    return {
      valido: false,
      mensaje: 'El periodo de registro para esta reunión ya ha finalizado.',
    };
  }

  const estado = diffMinutos <= (evento.toleranciaMin || 20) ? 'presente' : 'tardio';
  return { valido: true, estado, ahora };
};

const checkInQR = async (req, res) => {
  try {
    const { eventoId } = req.body;
    const usuarioId = req.usuario.id; // Corrección IDOR/BOLA: extraído directamente del token JWT

    if (!eventoId) {
      return res.status(400).json({ mensaje: 'El eventoId es obligatorio' });
    }

    const evento = await Evento.findByPk(eventoId);
    if (!evento) {
      return res.status(404).json({ mensaje: 'Evento no encontrado' });
    }

    const usuario = await Usuario.findByPk(usuarioId);
    if (!usuario) {
      return res.status(404).json({ mensaje: 'Usuario no encontrado' });
    }

    const validacionTiempo = calcularEstadoAsistencia(evento);
    if (!validacionTiempo.valido) {
      return res.status(400).json({ mensaje: validacionTiempo.mensaje });
    }

    let participante = await Participante.findOne({ where: { usuarioId, eventoId } });

    if (evento.tipoReunion === 'solo_miembros' && !participante) {
      return res.status(403).json({ mensaje: 'No está convocado a esta reunión' });
    }

    if (!participante) {
      participante = await Participante.create({ usuarioId, eventoId });
    }

    const yaRegistrado = await Asistencia.findOne({ where: { participanteId: participante.id } });
    if (yaRegistrado) {
      return res.status(409).json({ mensaje: 'El participante ya tiene asistencia registrada' });
    }

    const asistencia = await Asistencia.create({
      participanteId: participante.id,
      horaIngreso: validacionTiempo.ahora,
      metodo: 'qr',
      estado: validacionTiempo.estado,
    });

    res.json({ mensaje: `Asistencia registrada como ${validacionTiempo.estado}`, asistencia });
  } catch (error) {
    console.error('Error en checkInQR:', error);
    res.status(500).json({ mensaje: 'Error interno del servidor al registrar asistencia' });
  }
};

const checkInInvitado = async (req, res) => {
  try {
    const { eventoId, nombre, cedula } = req.body;

    if (!eventoId || !nombre || !cedula) {
      return res.status(400).json({ mensaje: 'eventoId, nombre y cedula son obligatorios' });
    }

    const evento = await Evento.findByPk(eventoId);
    if (!evento) {
      return res.status(404).json({ mensaje: 'Evento no encontrado' });
    }

    if (evento.tipoReunion === 'solo_miembros') {
      return res.status(403).json({ mensaje: 'Esta reunión no permite invitados' });
    }

    const validacionTiempo = calcularEstadoAsistencia(evento);
    if (!validacionTiempo.valido) {
      return res.status(400).json({ mensaje: validacionTiempo.mensaje });
    }

    const cedulaLimpia = String(cedula).trim();
    const nombreLimpio = String(nombre).trim();

    let usuario = await Usuario.findOne({ where: { cedula: cedulaLimpia } });
    if (!usuario) {
      usuario = await Usuario.create({
        nombre: nombreLimpio,
        cedula: cedulaLimpia,
        correo: `invitado_${cedulaLimpia}@temp.com`,
        passwordHash: '-',
        rol: 'Invitado',
      });
    }

    let participante = await Participante.findOne({ where: { usuarioId: usuario.id, eventoId } });
    if (!participante) {
      participante = await Participante.create({ usuarioId: usuario.id, eventoId });
    }

    const yaRegistrado = await Asistencia.findOne({ where: { participanteId: participante.id } });
    if (yaRegistrado) {
      return res.status(409).json({ mensaje: 'Ya tiene asistencia registrada' });
    }

    const asistencia = await Asistencia.create({
      participanteId: participante.id,
      horaIngreso: validacionTiempo.ahora,
      metodo: 'qr',
      estado: validacionTiempo.estado,
    });

    res.json({ mensaje: `Invitado registrado como ${validacionTiempo.estado}`, asistencia });
  } catch (error) {
    console.error('Error en checkInInvitado:', error);
    res.status(500).json({ mensaje: 'Error interno del servidor al registrar invitado' });
  }
};

const checkInManual = async (req, res) => {
  try {
    const { id } = req.params; // eventoId
    const { usuarioId, nombre, cedula, estadoPersonalizado } = req.body;

    const evento = await Evento.findByPk(id);
    if (!evento) {
      return res.status(404).json({ mensaje: 'Evento no encontrado' });
    }

    let usuario;

    if (usuarioId) {
      usuario = await Usuario.findByPk(usuarioId);
      if (!usuario) {
        return res.status(404).json({ mensaje: 'Usuario no encontrado' });
      }
    } else if (nombre && cedula) {
      if (evento.tipoReunion === 'solo_miembros') {
        return res.status(403).json({ mensaje: 'Esta reunión no permite invitados' });
      }
      const cedulaLimpia = String(cedula).trim();
      const nombreLimpio = String(nombre).trim();

      usuario = await Usuario.findOne({ where: { cedula: cedulaLimpia } });
      if (!usuario) {
        usuario = await Usuario.create({
          nombre: nombreLimpio,
          cedula: cedulaLimpia,
          correo: `invitado_${cedulaLimpia}@temp.com`,
          passwordHash: '-',
          rol: 'Invitado',
        });
      }
    } else {
      return res.status(400).json({ mensaje: 'Se requiere usuarioId, o bien nombre y cedula' });
    }

    let participante = await Participante.findOne({ where: { usuarioId: usuario.id, eventoId: id } });

    if (evento.tipoReunion === 'solo_miembros' && !participante) {
      return res.status(403).json({ mensaje: 'No está convocado a esta reunión' });
    }

    if (!participante) {
      participante = await Participante.create({ usuarioId: usuario.id, eventoId: id });
    }

    const yaRegistrado = await Asistencia.findOne({ where: { participanteId: participante.id } });
    if (yaRegistrado) {
      return res.status(409).json({ mensaje: 'Ya tiene asistencia registrada' });
    }

    const ahora = new Date();
    let estado = estadoPersonalizado;
    if (!estado || !['presente', 'tardio', 'ausente'].includes(estado)) {
      const validacion = calcularEstadoAsistencia(evento);
      estado = validacion.valido ? validacion.estado : 'tardio';
    }

    const asistencia = await Asistencia.create({
      participanteId: participante.id,
      horaIngreso: ahora,
      metodo: 'manual',
      estado,
    });

    res.json({ mensaje: `Asistencia manual registrada como ${estado}`, asistencia });
  } catch (error) {
    console.error('Error en checkInManual:', error);
    res.status(500).json({ mensaje: 'Error interno del servidor al registrar asistencia manual' });
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

    const detalle = participantes.map(p => ({
      nombre: p.Usuario ? p.Usuario.nombre : 'Desconocido',
      cedula: p.Usuario ? p.Usuario.cedula : '',
      correo: p.Usuario ? p.Usuario.correo : '',
      estado: p.Asistencia ? p.Asistencia.estado : 'ausente',
      metodo: p.Asistencia ? p.Asistencia.metodo : null,
      horaIngreso: p.Asistencia ? p.Asistencia.horaIngreso : null,
    }));

    res.json({
      evento: evento.nombre,
      fecha: evento.fecha,
      total: detalle.length,
      presentes: detalle.filter(p => p.estado === 'presente').length,
      tardios: detalle.filter(p => p.estado === 'tardio').length,
      ausentes: detalle.filter(p => p.estado === 'ausente').length,
      detalle,
    });
  } catch (error) {
    console.error('Error en reporte:', error);
    res.status(500).json({ mensaje: 'Error interno del servidor al generar reporte' });
  }
};

module.exports = { checkInQR, checkInInvitado, checkInManual, reporte };