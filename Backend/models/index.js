const Usuario = require('./usuario');
const Evento = require('./evento');
const Asistencia = require('./asistencia');
const Participante = require('./participante');

// Un Evento es creado por un Usuario (Administrador)
Usuario.hasMany(Evento, { foreignKey: 'creadorId', as: 'eventosCreados' });
Evento.belongsTo(Usuario, { foreignKey: 'creadorId', as: 'creador' });

// Relación de Asistencia (Usuario participa en Evento)
Usuario.hasMany(Asistencia, { foreignKey: 'usuarioId' });
Asistencia.belongsTo(Usuario, { foreignKey: 'usuarioId' });

Evento.hasMany(Asistencia, { foreignKey: 'eventoId' });
Asistencia.belongsTo(Evento, { foreignKey: 'eventoId' });

// Relación de Participante (Convocatoria)
Usuario.hasMany(Participante, { foreignKey: 'usuarioId' });
Participante.belongsTo(Usuario, { foreignKey: 'usuarioId' });

Evento.hasMany(Participante, { foreignKey: 'eventoId' });
Participante.belongsTo(Evento, { foreignKey: 'eventoId' });

module.exports = {
  Usuario,
  Evento,
  Asistencia,
  Participante,
};
