const { DataTypes } = require('sequelize');
const { sequelize } = require('../config/db');

const Asistencia = sequelize.define('Asistencia', {
  id: {
    type: DataTypes.INTEGER,
    primaryKey: true,
    autoIncrement: true,
  },
  estado: {
    type: DataTypes.ENUM('Presente', 'Ausente', 'Tardanza', 'Justificado', 'Invitado'),
    allowNull: false,
    defaultValue: 'Presente',
  },
  horaRegistro: {
    type: DataTypes.DATE,
    defaultValue: DataTypes.NOW,
  },
  esInvitado: {
    type: DataTypes.BOOLEAN,
    defaultValue: false,
  },
  invitadoNombre: {
    type: DataTypes.STRING,
    allowNull: true,
  },
  invitadoCedula: {
    type: DataTypes.STRING,
    allowNull: true,
  },
  tipo_registro: {
    type: DataTypes.ENUM('QR', 'Manual'),
    allowNull: false,
    defaultValue: 'QR',
  },
  registrado_por: {
    type: DataTypes.INTEGER,
    allowNull: true,
  },
}, {
  tableName: 'asistencias',
  timestamps: true,
});

module.exports = Asistencia;
