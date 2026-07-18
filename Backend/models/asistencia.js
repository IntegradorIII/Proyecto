const { DataTypes } = require('sequelize');
const { sequelize } = require('../config/db');

const Asistencia = sequelize.define('Asistencia', {
  id: {
    type: DataTypes.INTEGER,
    primaryKey: true,
    autoIncrement: true,
  },
  estado: {
    type: DataTypes.ENUM('Presente', 'Ausente', 'Tardanza', 'Justificado'),
    allowNull: false,
    defaultValue: 'Presente',
  },
  horaRegistro: {
    type: DataTypes.DATE,
    defaultValue: DataTypes.NOW,
  },
}, {
  tableName: 'asistencias',
  timestamps: true,
});

module.exports = Asistencia;
