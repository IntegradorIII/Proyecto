const Asistencia = require('../models/Asistencia');
const Participante = require('../models/Participante');
const Evento = require('../models/Evento');
const Usuario = require('../models/Usuario');

const checkInQR = async (req, res) => {
  try {
    const { usuarioId, eventoId } = req.body;

    const evento = await Evento.findByPk(eventoId);
    if (!evento) {
      return res.status(404).json({ mensaje: 'Evento no encontrado' });
    }

    const usuario = await Usuario.findByPk(usuarioId);
    if (!usuario) {
      return res.status(404).json({ mensaje: 'Usuario no encontrado' });
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

    const ahora = new Date();
    const horaEvento = new Date(ahora.toDateString() + ' ' + evento.hora);
    const diffMinutos = (ahora - horaEvento) / (1000 * 60);
    const estado = diffMinutos <= evento.toleranciaMin ? 'presente' : 'tardio';

    const asistencia = await Asistencia.create({
      participanteId: participante.id,
      horaIngreso: ahora,
      metodo: 'qr',
      estado,
    });

    res.json({ mensaje: `Asistencia registrada como ${estado}`, asistencia });
  } catch (error) {
    console.error('Error en checkInQR:', error);
    res.status(500).json({ mensaje: 'Error al registrar asistencia', error: error.message });
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

    let usuario = await Usuario.findOne({ where: { cedula } });
    if (!usuario) {
      usuario = await Usuario.create({
        nombre,
        cedula,
        correo: `invitado_${cedula}@temp.com`,
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

    const ahora = new Date();
    const horaEvento = new Date(ahora.toDateString() + ' ' + evento.hora);
    const diffMinutos = (ahora - horaEvento) / (1000 * 60);
    const estado = diffMinutos <= evento.toleranciaMin ? 'presente' : 'tardio';

    const asistencia = await Asistencia.create({
      participanteId: participante.id,
      horaIngreso: ahora,
      metodo: 'qr',
      estado,
    });

    res.json({ mensaje: `Invitado registrado como ${estado}`, asistencia });
  } catch (error) {
    console.error('Error en checkInInvitado:', error);
    res.status(500).json({ mensaje: 'Error al registrar invitado', error: error.message });
  }
};

const checkInManual = async (req, res) => {
  try {
    const { id } = req.params; // eventoId
    const { usuarioId, nombre, cedula } = req.body;

    const evento = await Evento.findByPk(id);
    if (!evento) {
      return res.status(404).json({ mensaje: 'Evento no encontrado' });
    }

    let usuario;

    if (usuarioId) {
      // Caso: es un Miembro que el operador ya identifica por su cuenta
      usuario = await Usuario.findByPk(usuarioId);
      if (!usuario) {
        return res.status(404).json({ mensaje: 'Usuario no encontrado' });
      }
    } else if (nombre && cedula) {
      // Caso: es un Invitado, el operador toma los datos a mano
      if (evento.tipoReunion === 'solo_miembros') {
        return res.status(403).json({ mensaje: 'Esta reunión no permite invitados' });
      }
      usuario = await Usuario.findOne({ where: { cedula } });
      if (!usuario) {
        usuario = await Usuario.create({
          nombre,
          cedula,
          correo: `invitado_${cedula}@temp.com`,
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
    const horaEvento = new Date(ahora.toDateString() + ' ' + evento.hora);
    const diffMinutos = (ahora - horaEvento) / (1000 * 60);
    const estado = diffMinutos <= evento.toleranciaMin ? 'presente' : 'tardio';

    const asistencia = await Asistencia.create({
      participanteId: participante.id,
      horaIngreso: ahora,
      metodo: 'manual',
      estado,
    });

    res.json({ mensaje: `Asistencia manual registrada como ${estado}`, asistencia });
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

module.exports = { checkInQR, checkInInvitado, checkInManual, reporte };