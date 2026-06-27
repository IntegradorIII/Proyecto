const { Sequelize } = require('sequelize');
require('dotenv').config();

const sequelize = new Sequelize(
  process.env.DB_NAME,
  process.env.DB_USER,
  process.env.DB_PASSWORD,
  {
    host: process.env.DB_HOST,
    port: process.env.DB_PORT,
    dialect: 'postgres',
    logging: false,
  }
);

const conectar = async () => {
  try {
    await sequelize.authenticate();
    console.log('Conexion a PostgreSQL establecida correctamente');
  } catch (error) {
    console.error('Error al conectar a la base de datos:', error);
  }
};

module.exports = { sequelize, conectar };