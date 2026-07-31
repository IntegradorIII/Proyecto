const { Sequelize } = require('sequelize');
require('dotenv').config();

const sequelize = new Sequelize(process.env.DATABASE_URL, {
  dialect: 'postgres',
  dialectOptions: {
    ssl: {
      require: true,
      rejectUnauthorized: false,
    },
  },
  logging: false,
});

const conectar = async () => {
  try {
    await sequelize.authenticate();
    console.log('Conexion a PostgreSQL en Render establecida correctamente');
  } catch (error) {
    console.error('Error al conectar a la base de datos:', error);
  }
};

module.exports = { sequelize, conectar };