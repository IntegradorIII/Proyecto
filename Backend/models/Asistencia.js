const { DataTypes } = require('sequelize');
const { sequelize } = require('../config/db');
const Participante = require('./Participante');

const Asistencia = sequelize.define('Asistencia', {
  id: {
    type: DataTypes.INTEGER,
    primaryKey: true,
    autoIncrement: true,
  },
  participanteId: {
    type: DataTypes.INTEGER,
    allowNull: false,
    references: { model: Participante, key: 'id' },
  },
  horaIngreso: {
    type: DataTypes.DATE,
    allowNull: false,
    defaultValue: DataTypes.NOW,
  },
  metodo: {
    type: DataTypes.ENUM('qr', 'manual'),
    allowNull: false,
  },
  estado: {
    type: DataTypes.ENUM('presente', 'tardio', 'ausente'),
    allowNull: false,
    defaultValue: 'presente',
  },
}, {
  tableName: 'asistencias',
  timestamps: true,
});

Participante.hasOne(Asistencia, { foreignKey: 'participanteId' });
Asistencia.belongsTo(Participante, { foreignKey: 'participanteId' });

module.exports = Asistencia;