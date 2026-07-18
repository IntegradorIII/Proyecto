const { DataTypes } = require('sequelize');
const { sequelize } = require('../config/db');

const Participante = sequelize.define('Participante', {
  id: {
    type: DataTypes.INTEGER,
    primaryKey: true,
    autoIncrement: true,
  },
  // La clave foránea de usuarioId y eventoId será inyectada en index.js
}, {
  tableName: 'participantes',
  timestamps: true,
});

module.exports = Participante;
