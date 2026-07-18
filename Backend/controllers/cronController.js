const cron = require('node-cron');
const { Evento, Participante, Asistencia } = require('../models');
const { Op } = require('sequelize');

const iniciarCronCierreEventos = () => {
  // Ejecutar cada 10 minutos
  cron.schedule('*/10 * * * *', async () => {
    try {
      console.log('--- Iniciando Cron Job: Revisión de Cierre de Eventos ---');
      const ahora = new Date();
      const fechaActual = ahora.toISOString().split('T')[0];
      const horaActual = ahora.toTimeString().split(' ')[0]; // formato HH:MM:SS

      // Buscar eventos no cerrados, cuya fecha ya pasó, o cuya fecha es hoy y la horaFin ya pasó
      const eventosFinalizados = await Evento.findAll({
        where: {
          cerrado: false,
          [Op.or]: [
            {
              fecha: { [Op.lt]: fechaActual }
            },
            {
              fecha: fechaActual,
              horaFin: { [Op.lt]: horaActual }
            }
          ]
        }
      });

      if (eventosFinalizados.length === 0) {
        return;
      }

      for (const evento of eventosFinalizados) {
        console.log(`Cerrando evento ID: ${evento.id} - ${evento.titulo}`);

        // Buscar a todos los participantes convocados
        const participantes = await Participante.findAll({
          where: { eventoId: evento.id }
        });

        // Buscar a todos los que ya tienen registro de asistencia
        const asistenciasRegistradas = await Asistencia.findAll({
          where: { eventoId: evento.id }
        });

        const usuariosConAsistencia = asistenciasRegistradas.map(a => a.usuarioId);

        // Filtrar participantes que NO tienen asistencia
        const participantesAusentes = participantes.filter(p => !usuariosConAsistencia.includes(p.usuarioId));

        if (participantesAusentes.length > 0) {
          // Crear los registros de ausentismo masivo
          const registrosAusentes = participantesAusentes.map(p => ({
            eventoId: evento.id,
            usuarioId: p.usuarioId,
            estado: 'Ausente'
          }));

          await Asistencia.bulkCreate(registrosAusentes);
          console.log(`Se registraron ${registrosAusentes.length} ausencias para el evento ${evento.id}`);
        }

        // Marcar el evento como cerrado
        evento.cerrado = true;
        await evento.save();
      }

      console.log('--- Fin del Cron Job ---');
    } catch (error) {
      console.error('Error en el Cron Job de Cierre de Eventos:', error);
    }
  });
};

module.exports = {
  iniciarCronCierreEventos
};
