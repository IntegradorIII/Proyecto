require('dotenv').config();
const express = require('express');
const cors = require('cors');
const { sequelize, conectar } = require('./config/db');
const Usuario = require('./models/Usuario');
const authRoutes = require('./routes/authRoutes');

const app = express();
app.use(cors());
app.use(express.json());

app.get('/', (req, res) => {
  res.send('API de Asistencia corriendo correctamente');
});

app.use('/api/auth', authRoutes);

const PORT = process.env.PORT || 3000;

const iniciar = async () => {
  await conectar();
  await sequelize.sync();
  app.listen(PORT, () => {
    console.log(`Servidor corriendo en http://localhost:${PORT}`);
  });
};

iniciar();