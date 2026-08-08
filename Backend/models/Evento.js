const { DataTypes } = require('sequelize');
const { sequelize } = require('../config/db');

const Evento = sequelize.define('Evento', {
  id: {
    type: DataTypes.INTEGER,
    primaryKey: true,
    autoIncrement: true,
  },
  nombre: { type: DataTypes.STRING, allowNull: false },
  fecha: { type: DataTypes.DATEONLY, allowNull: false },
  hora: { type: DataTypes.TIME, allowNull: false },
  lugar: { type: DataTypes.STRING, allowNull: false },
  toleranciaMin: { type: DataTypes.INTEGER, defaultValue: 20 },
  tipoReunion: {
    type: DataTypes.ENUM('solo_miembros', 'abierta'),
    allowNull: false,
    defaultValue: 'solo_miembros',
  },
  codigoQr: {
    type: DataTypes.TEXT,
    allowNull: true,
  },
}, { tableName: 'eventos', timestamps: true });

module.exports = Evento;