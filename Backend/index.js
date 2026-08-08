require('dotenv').config();
const express = require('express');
const cors = require('cors');
const { sequelize, conectar } = require('./config/db');
const Usuario = require('./models/Usuario');
const Evento = require('./models/Evento');
const Participante = require('./models/Participante');
const Asistencia = require('./models/Asistencia');
const authRoutes = require('./routes/authRoutes');
const eventoRoutes = require('./routes/eventoRoutes');
const participanteRoutes = require('./routes/participanteRoutes');
const asistenciaRoutes = require('./routes/asistenciaRoutes');
const usuarioRoutes = require('./routes/usuarioRoutes');

const app = express();
app.use(cors());
app.use(express.json());

app.get('/', (req, res) => {
  res.send('API de Asistencia corriendo correctamente');
});

app.use('/api/auth', authRoutes);
app.use('/api/eventos', eventoRoutes);
app.use('/api/participantes', participanteRoutes);
app.use('/api/asistencia', asistenciaRoutes);
app.use('/api/usuarios', usuarioRoutes);

const PORT = process.env.PORT || 3000;

const iniciar = async () => {
  await conectar();
  await sequelize.sync({ alter: true });
  app.listen(PORT, () => {
    console.log(`Servidor corriendo en http://localhost:${PORT}`);
  });
};

iniciar();