const Evento = require('../models/Evento');

const getSharedCss = () => `
  :root {
    --primary: #4f46e5;
    --primary-hover: #4338ca;
    --primary-light: #eef2ff;
    --success: #10b981;
    --success-bg: #ecfdf5;
    --warning: #f59e0b;
    --warning-bg: #fffbeb;
    --danger: #ef4444;
    --danger-bg: #fef2f2;
    --dark: #0f172a;
    --gray-700: #334155;
    --gray-500: #64748b;
    --gray-300: #cbd5e1;
    --gray-100: #f1f5f9;
    --card-bg: rgba(255, 255, 255, 0.95);
    --radius: 16px;
    --shadow: 0 20px 25px -5px rgba(0, 0, 0, 0.1), 0 10px 10px -5px rgba(0, 0, 0, 0.04);
  }

  * {
    box-sizing: border-box;
    margin: 0;
    padding: 0;
    font-family: 'Plus Jakarta Sans', -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
  }

  body {
    min-height: 100vh;
    background: linear-gradient(135deg, #0f172a 0%, #1e1b4b 50%, #312e81 100%);
    display: flex;
    align-items: center;
    justify-content: center;
    padding: 20px;
    color: var(--dark);
  }

  .container {
    width: 100%;
    max-width: 480px;
    background: var(--card-bg);
    backdrop-filter: blur(12px);
    border-radius: var(--radius);
    padding: 32px 28px;
    box-shadow: var(--shadow);
    border: 1px solid rgba(255, 255, 255, 0.2);
    animation: fadeIn 0.4s ease-out;
  }

  @keyframes fadeIn {
    from { opacity: 0; transform: translateY(12px); }
    to { opacity: 1; transform: translateY(0); }
  }

  .header {
    text-align: center;
    margin-bottom: 24px;
  }

  .app-badge {
    display: inline-flex;
    align-items: center;
    gap: 6px;
    padding: 6px 14px;
    border-radius: 9999px;
    font-size: 12px;
    font-weight: 700;
    text-transform: uppercase;
    letter-spacing: 0.5px;
    margin-bottom: 12px;
  }

  .badge-members {
    background: #e0e7ff;
    color: #3730a3;
  }

  .badge-open {
    background: #dcfce7;
    color: #166534;
  }

  .meeting-title {
    font-size: 22px;
    font-weight: 800;
    color: var(--dark);
    line-height: 1.3;
    margin-bottom: 8px;
  }

  .meeting-details {
    background: var(--gray-100);
    border-radius: 12px;
    padding: 12px 16px;
    margin-bottom: 24px;
    font-size: 13px;
    color: var(--gray-700);
    display: flex;
    flex-direction: column;
    gap: 6px;
    border: 1px solid var(--gray-300);
  }

  .detail-row {
    display: flex;
    align-items: center;
    gap: 8px;
  }

  .detail-row svg {
    width: 16px;
    height: 16px;
    color: var(--primary);
    flex-shrink: 0;
  }

  .form-group {
    margin-bottom: 18px;
    text-align: left;
  }

  label {
    display: block;
    font-size: 13px;
    font-weight: 600;
    color: var(--gray-700);
    margin-bottom: 6px;
  }

  .input-wrapper {
    position: relative;
    display: flex;
    align-items: center;
  }

  .input-wrapper svg {
    position: absolute;
    left: 14px;
    width: 18px;
    height: 18px;
    color: var(--gray-500);
    pointer-events: none;
  }

  input {
    width: 100%;
    padding: 12px 14px 12px 42px;
    border: 1.5px solid var(--gray-300);
    border-radius: 10px;
    font-size: 15px;
    color: var(--dark);
    outline: none;
    transition: all 0.2s ease;
    background: #ffffff;
  }

  input:focus {
    border-color: var(--primary);
    box-shadow: 0 0 0 3px rgba(79, 70, 229, 0.15);
  }

  .btn {
    width: 100%;
    padding: 14px;
    border: none;
    border-radius: 10px;
    font-size: 15px;
    font-weight: 700;
    cursor: pointer;
    transition: all 0.2s ease;
    display: flex;
    align-items: center;
    justify-content: center;
    gap: 8px;
  }

  .btn-primary {
    background: var(--primary);
    color: #ffffff;
    box-shadow: 0 4px 12px rgba(79, 70, 229, 0.3);
  }

  .btn-primary:hover:not(:disabled) {
    background: var(--primary-hover);
    transform: translateY(-1px);
    box-shadow: 0 6px 16px rgba(79, 70, 229, 0.4);
  }

  .btn:disabled {
    opacity: 0.65;
    cursor: not-allowed;
  }

  .footer-links {
    margin-top: 20px;
    text-align: center;
    font-size: 13px;
    color: var(--gray-500);
  }

  .footer-links a {
    color: var(--primary);
    font-weight: 600;
    text-decoration: none;
  }

  .footer-links a:hover {
    text-decoration: underline;
  }

  .alert {
    padding: 12px 16px;
    border-radius: 10px;
    font-size: 13px;
    font-weight: 500;
    margin-bottom: 18px;
    display: none;
    line-height: 1.4;
  }

  .alert-danger {
    background: var(--danger-bg);
    color: #991b1b;
    border: 1px solid #fecaca;
  }

  .alert-warning {
    background: var(--warning-bg);
    color: #92400e;
    border: 1px solid #fde68a;
  }

  .result-card {
    display: none;
    text-align: center;
    padding: 20px 10px;
    animation: fadeIn 0.4s ease-out;
  }

  .result-icon {
    width: 64px;
    height: 64px;
    border-radius: 50%;
    display: inline-flex;
    align-items: center;
    justify-content: center;
    margin-bottom: 16px;
  }

  .result-icon.success {
    background: var(--success-bg);
    color: var(--success);
  }

  .result-icon.warning {
    background: var(--warning-bg);
    color: var(--warning);
  }

  .status-pill {
    display: inline-block;
    padding: 6px 16px;
    border-radius: 9999px;
    font-weight: 800;
    font-size: 14px;
    text-transform: uppercase;
    letter-spacing: 0.5px;
    margin: 10px 0 16px;
  }

  .status-presente {
    background: #dcfce7;
    color: #15803d;
    border: 1px solid #86efac;
  }

  .status-tardio {
    background: #fef3c7;
    color: #b45309;
    border: 1px solid #fcd34d;
  }

  .info-box {
    background: var(--gray-100);
    border-radius: 12px;
    padding: 16px;
    margin-top: 16px;
    text-align: left;
    font-size: 13px;
    color: var(--gray-700);
  }

  .spinner {
    width: 18px;
    height: 18px;
    border: 2.5px solid rgba(255, 255, 255, 0.3);
    border-top-color: #ffffff;
    border-radius: 50%;
    animation: spin 0.6s linear infinite;
    display: none;
  }

  @keyframes spin {
    to { transform: rotate(360deg); }
  }
`;

const renderMemberLoginView = (evento) => `
<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Acceso de Miembros · ${evento.nombre}</title>
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700;800&display=swap" rel="stylesheet">
  <style>${getSharedCss()}</style>
</head>
<body>
  <div class="container">
    <div id="formSection">
      <div class="header">
        <span class="app-badge badge-members">
          <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z"/></svg>
          Solo Miembros Convocados
        </span>
        <h1 class="meeting-title">${evento.nombre}</h1>
      </div>

      <div class="meeting-details">
        <div class="detail-row">
          <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect x="3" y="4" width="18" height="18" rx="2" ry="2"/><line x1="16" y1="2" x2="16" y2="6"/><line x1="8" y1="2" x2="8" y2="6"/><line x1="3" y1="10" x2="21" y2="10"/></svg>
          <span><strong>Fecha:</strong> ${evento.fecha} &nbsp;|&nbsp; <strong>Hora:</strong> ${evento.hora}</span>
        </div>
        <div class="detail-row">
          <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M21 10c0 7-9 13-9 13s-9-6-9-13a9 9 0 0 1 18 0z"/><circle cx="12" cy="10" r="3"/></svg>
          <span><strong>Lugar:</strong> ${evento.lugar}</span>
        </div>
        <div class="detail-row">
          <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="12" cy="12" r="10"/><polyline points="12 6 12 12 16 14"/></svg>
          <span><strong>Tolerancia:</strong> ${evento.toleranciaMin} min</span>
        </div>
      </div>

      <div id="alertBox" class="alert"></div>

      <form id="loginForm" onsubmit="handleLogin(event)">
        <div class="form-group">
          <label for="correo">Correo Electrónico</label>
          <div class="input-wrapper">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M4 4h16c1.1 0 2 .9 2 2v12c0 1.1-.9 2-2 2H4c-1.1 0-2-.9-2-2V6c0-1.1.9-2 2-2z"/><polyline points="22,6 12,13 2,6"/></svg>
            <input type="email" id="correo" required placeholder="usuario@institucion.com" autocomplete="email">
          </div>
        </div>

        <div class="form-group">
          <label for="password">Contraseña</label>
          <div class="input-wrapper">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect x="3" y="11" width="18" height="11" rx="2" ry="2"/><path d="M7 11V7a5 5 0 0 1 10 0v4"/></svg>
            <input type="password" id="password" required placeholder="••••••••" autocomplete="current-password">
          </div>
        </div>

        <button type="submit" id="submitBtn" class="btn btn-primary">
          <span class="spinner" id="spinner"></span>
          <span id="btnText">Iniciar Sesión e Ingresar</span>
        </button>
      </form>

      ${evento.tipoReunion !== 'abierta' ? `
        <div class="footer-links">
          <span>Esta reunión es de acceso privado exclusivo para miembros convocados.</span>
        </div>
      ` : ''}
    </div>

    <div id="resultSection" class="result-card">
      <div class="result-icon success" id="resultIcon">
        <svg width="36" height="36" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="3"><polyline points="20 6 9 17 4 12"/></svg>
      </div>
      <h2 style="font-size: 20px; font-weight: 800;" id="resultTitle">¡Asistencia Confirmada!</h2>
      <div id="statusPill" class="status-pill status-presente">Presente</div>
      <p style="font-size: 14px; color: var(--gray-700);" id="resultMessage"></p>
      
      <div class="info-box" id="infoBox">
        <p><strong>Colaborador:</strong> <span id="resNombre"></span></p>
        <p><strong>Correo:</strong> <span id="resCorreo"></span></p>
        <p><strong>Hora de Ingreso:</strong> <span id="resHora"></span></p>
      </div>
    </div>
  </div>

  <script>
    const EVENTO_ID = ${evento.id};

    async function handleLogin(e) {
      e.preventDefault();
      const correo = document.getElementById('correo').value.trim();
      const password = document.getElementById('password').value;
      const alertBox = document.getElementById('alertBox');
      const submitBtn = document.getElementById('submitBtn');
      const spinner = document.getElementById('spinner');
      const btnText = document.getElementById('btnText');

      alertBox.style.display = 'none';
      submitBtn.disabled = true;
      spinner.style.display = 'inline-block';
      btnText.textContent = 'Verificando y registrando...';

      try {
        const loginRes = await fetch('/api/auth/login', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({ correo, password })
        });
        const loginData = await loginRes.json();

        if (!loginRes.ok) {
          throw new Error(loginData.mensaje || 'Credenciales incorrectas');
        }

        const token = loginData.token;
        const usuario = loginData.usuario;

        const checkinRes = await fetch('/api/asistencia/check-in-qr', {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer ' + token
          },
          body: JSON.stringify({ eventoId: EVENTO_ID })
        });
        const checkinData = await checkinRes.json();

        if (!checkinRes.ok) {
          throw new Error(checkinData.mensaje || 'Error al registrar asistencia');
        }

        document.getElementById('formSection').style.display = 'none';
        document.getElementById('resultSection').style.display = 'block';

        const estado = (checkinData.asistencia?.estado || 'presente').toLowerCase();
        const statusPill = document.getElementById('statusPill');
        statusPill.textContent = estado === 'tardio' ? 'Tardío' : 'Presente';
        statusPill.className = 'status-pill ' + (estado === 'tardio' ? 'status-tardio' : 'status-presente');

        document.getElementById('resultMessage').textContent = 'Tu asistencia ha sido registrada exitosamente en la reunión.';
        document.getElementById('resNombre').textContent = usuario.nombre;
        document.getElementById('resCorreo').textContent = usuario.correo;
        document.getElementById('resHora').textContent = new Date().toLocaleTimeString();

      } catch (err) {
        alertBox.textContent = err.message;
        alertBox.className = 'alert alert-danger';
        alertBox.style.display = 'block';
        submitBtn.disabled = false;
        spinner.style.display = 'none';
        btnText.textContent = 'Iniciar Sesión e Ingresar';
      }
    }
  </script>
</body>
</html>
`;

const renderGuestFormView = (evento) => `
<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Reunión Abierta · ${evento.nombre}</title>
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700;800&display=swap" rel="stylesheet">
  <style>${getSharedCss()}</style>
</head>
<body>
  <div class="container" style="text-align: center;">
    <span class="app-badge badge-open">
      <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><circle cx="12" cy="12" r="10"/><line x1="2" y1="12" x2="22" y2="12"/><path d="M12 2a15.3 15.3 0 0 1 4 10 15.3 15.3 0 0 1-4 10 15.3 15.3 0 0 1-4-10 15.3 15.3 0 0 1 4-10z"/></svg>
      Reunión Abierta a Invitados
    </span>

    <h1 class="meeting-title" style="margin-top: 12px;">${evento.nombre}</h1>

    <div class="meeting-details" style="text-align: left;">
      <div class="detail-row">
        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect x="3" y="4" width="18" height="18" rx="2" ry="2"/><line x1="16" y1="2" x2="16" y2="6"/><line x1="8" y1="2" x2="8" y2="6"/><line x1="3" y1="10" x2="21" y2="10"/></svg>
        <span><strong>Fecha:</strong> ${evento.fecha} &nbsp;|&nbsp; <strong>Hora:</strong> ${evento.hora}</span>
      </div>
      <div class="detail-row">
        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M21 10c0 7-9 13-9 13s-9-6-9-13a9 9 0 0 1 18 0z"/><circle cx="12" cy="10" r="3"/></svg>
        <span><strong>Lugar:</strong> ${evento.lugar}</span>
      </div>
    </div>

    <div class="info-box" style="text-align: left;">
      <p>Esta es una reunión abierta. Tu asistencia como invitado debe ser registrada por el personal a cargo (Operador o Administrador) en el punto de entrada.</p>
    </div>
  </div>
</body>
</html>
`;

const renderNotFoundView = () => `
<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Reunión No Encontrada</title>
  <style>${getSharedCss()}</style>
</head>
<body>
  <div class="container" style="text-align: center;">
    <div class="result-icon warning">
      <svg width="36" height="36" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><circle cx="12" cy="12" r="10"/><line x1="12" y1="8" x2="12" y2="12"/><line x1="12" y1="16" x2="12.01" y2="16"/></svg>
    </div>
    <h1 style="font-size: 22px; font-weight: 800; margin-bottom: 8px;">Reunión No Encontrada</h1>
    <p style="font-size: 14px; color: var(--gray-500); margin-bottom: 24px;">El código QR o enlace escaneado no corresponde a ninguna reunión activa.</p>
  </div>
</body>
</html>
`;

const verReunion = async (req, res) => {
  try {
    const { id } = req.params;
    const evento = await Evento.findByPk(id);
    if (!evento) {
      return res.status(404).send(renderNotFoundView());
    }

    if (evento.tipoReunion === 'solo_miembros') {
      return res.redirect(`/reunion/${evento.id}/login`);
    } else {
      return res.redirect(`/reunion/${evento.id}/invitado`);
    }
  } catch (error) {
    console.error('Error en verReunion:', error);
    res.status(500).send(renderNotFoundView());
  }
};

const verLoginReunion = async (req, res) => {
  try {
    const id = req.params.id || req.query.reunionId;
    if (!id) {
      return res.status(404).send(renderNotFoundView());
    }
    const evento = await Evento.findByPk(id);
    if (!evento) {
      return res.status(404).send(renderNotFoundView());
    }
    return res.send(renderMemberLoginView(evento));
  } catch (error) {
    console.error('Error en verLoginReunion:', error);
    res.status(500).send(renderNotFoundView());
  }
};

const verInvitadoReunion = async (req, res) => {
  try {
    const id = req.params.id || req.query.reunionId;
    if (!id) {
      return res.status(404).send(renderNotFoundView());
    }
    const evento = await Evento.findByPk(id);
    if (!evento) {
      return res.status(404).send(renderNotFoundView());
    }
    return res.send(renderGuestFormView(evento));
  } catch (error) {
    console.error('Error en verInvitadoReunion:', error);
    res.status(500).send(renderNotFoundView());
  }
};

module.exports = {
  verReunion,
  verLoginReunion,
  verInvitadoReunion,
};