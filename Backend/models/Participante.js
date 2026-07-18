const { DataTypes } = require('sequelize');
const { sequelize } = require('../config/db');
const Usuario = require('./Usuario');
const Evento = require('./Evento');

const Participante = sequelize.define('Participante', {
  id: {
    type: DataTypes.INTEGER,
    primaryKey: true,
    autoIncrement: true,
  },
  usuarioId: {
    type: DataTypes.INTEGER,
    allowNull: false,
    references: { model: Usuario, key: 'id' },
  },
  eventoId: {
    type: DataTypes.INTEGER,
    allowNull: false,
    references: { model: Evento, key: 'id' },
  },
  codigoQr: {
    type: DataTypes.STRING,
    allowNull: true,
  },
}, {
  tableName: 'participantes',
  timestamps: true,
});

Usuario.hasMany(Participante, { foreignKey: 'usuarioId' });
Participante.belongsTo(Usuario, { foreignKey: 'usuarioId' });

Evento.hasMany(Participante, { foreignKey: 'eventoId' });
Participante.belongsTo(Evento, { foreignKey: 'eventoId' });

module.exports = Participante;