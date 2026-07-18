require('dotenv').config();
const express = require('express');
const cors = require('cors');
const { sequelize, conectar } = require('./config/db');
require('./models'); // Importar todos los modelos y relaciones
const authRoutes = require('./routes/authRoutes');
const eventRoutes = require('./routes/eventRoutes');
const asistenciaRoutes = require('./routes/asistenciaRoutes');

const app = express();
app.use(cors());
app.use(express.json());

app.get('/', (req, res) => {
  res.send('API de Asistencia corriendo correctamente');
});

app.use('/api/auth', authRoutes);
app.use('/api/eventos', eventRoutes);
app.use('/api/asistencias', asistenciaRoutes);

const { iniciarCronCierreEventos } = require('./controllers/cronController');

const PORT = process.env.PORT || 3000;

const iniciar = async () => {
  await conectar();
  await sequelize.sync();
  
  // Iniciar tareas automatizadas
  iniciarCronCierreEventos();

  app.listen(PORT, () => {
    console.log(`Servidor corriendo en http://localhost:${PORT}`);
  });
};

iniciar();