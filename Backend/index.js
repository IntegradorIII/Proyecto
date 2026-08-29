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
const reunionWebRoutes = require('./routes/reunionWebRoutes');
const path = require('path');
const app = express();
app.use(cors());
app.use(express.json());
// Servir los archivos estáticos de Flutter Web
app.use(express.static(path.join(__dirname, 'public')));
// Endpoints de la API REST
app.get('/api/health', (req, res) => {
  res.json({ status: 'ok', message: 'API de Asistencia corriendo correctamente' });
});
app.use('/', reunionWebRoutes);
app.use('/api/auth', authRoutes);
app.use('/api/eventos', eventoRoutes);
app.use('/api/participantes', participanteRoutes);
app.use('/api/asistencia', asistenciaRoutes);
app.use('/api/usuarios', usuarioRoutes);
// Servir la aplicación Flutter Web (SPA) para cualquier otra ruta no capturada por la API
app.use((req, res) => {
  res.sendFile(path.join(__dirname, 'public', 'index.html'));
});
const PORT = process.env.PORT || 3000;
const iniciar = async () => {
  await conectar();
  await sequelize.sync({ alter: true });
  return app.listen(PORT, () => {
    console.log(`Servidor corriendo en http://localhost:${PORT}`);
  });
};
if (require.main === module) {
  iniciar();
}
module.exports = { app, iniciar };