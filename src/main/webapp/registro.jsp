<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="com.miportafolio.dao.UsuarioDAO" %>
<%@ page import="com.miportafolio.model.Usuario" %>
<%
    /*
     * registro.jsp — Página de registro de nuevos usuarios.
     * Si ya hay sesión activa, redirige directamente al portafolio.
     * El formulario hace POST a /registro (RegistroServlet).
     */
    if (session != null && session.getAttribute("usuario") != null) {
        response.sendRedirect(request.getContextPath() + "/portafolio");
        return;
    }

    String ctx   = request.getContextPath();
    String error = request.getParameter("error");
    String ok    = request.getParameter("ok");
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
    <title>REGISTRO DE USUARIO // UPLA — Arquitectura de Software</title>
    <link href="https://fonts.googleapis.com/css2?family=Fira+Code:wght@400;600;700;800&family=Plus+Jakarta+Sans:wght@400;600;800;900&display=swap" rel="stylesheet">
    <style>
        * { box-sizing: border-box; margin: 0; padding: 0; }
        body {
            background: #05020c;
            font-family: 'Plus Jakarta Sans', sans-serif;
            color: #f5edff;
            min-height: 100vh;
            display: flex;
            justify-content: center;
            align-items: center;
            position: relative;
            overflow-x: hidden;
            padding: 20px;
        }
        canvas {
            position: fixed;
            top: 0; left: 0;
            width: 100%; height: 100%;
            z-index: 1;
            pointer-events: none;
        }
        .terminal-container {
            position: relative;
            z-index: 10;
            width: 100%;
            max-width: 480px;
        }
        .card {
            background: rgba(18,6,36,0.88);
            backdrop-filter: blur(25px);
            border: 1.5px solid rgba(216,132,255,0.45);
            border-radius: 26px;
            padding: 40px 32px;
            box-shadow: 0 0 55px rgba(216,132,255,0.35), 0 20px 60px rgba(0,0,0,0.85);
            animation: floatCard 6s ease-in-out infinite;
        }
        @keyframes floatCard {
            0%, 100% { transform: translateY(0); }
            50%       { transform: translateY(-6px); }
        }
        .header-tag {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 20px;
            font-family: 'Fira Code', monospace;
            font-size: 11px;
            color: #00f3ff;
            text-transform: uppercase;
            border-bottom: 1px dashed rgba(216,132,255,0.25);
            padding-bottom: 9px;
        }
        .status-dot {
            display: inline-block;
            width: 9px; height: 9px;
            background: #ff007f;
            border-radius: 50%;
            box-shadow: 0 0 10px #ff007f;
            margin-right: 6px;
            animation: pulseDot 2s infinite;
        }
        @keyframes pulseDot {
            0%, 100% { opacity: 1; transform: scale(1); }
            50%       { opacity: .4; transform: scale(.8); }
        }
        .logo-box {
            text-align: center;
            margin-bottom: 14px;
        }
        .logo-box img {
            height: 72px;
            filter: drop-shadow(0 0 20px rgba(216,132,255,0.85));
            transition: .3s;
        }
        .logo-box img:hover { transform: scale(1.06); }
        .title-box {
            text-align: center;
            margin-bottom: 24px;
        }
        .title-box h1 {
            font-family: 'Plus Jakarta Sans', sans-serif;
            font-size: 21px;
            font-weight: 900;
            background: linear-gradient(135deg, #fff 0%, #ff80df 40%, #00f3ff 100%);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            text-transform: uppercase;
            margin-bottom: 4px;
            filter: drop-shadow(0 0 14px rgba(216,132,255,.6));
        }
        .title-box p {
            font-size: 11.5px;
            color: #d0b8ee;
            font-family: 'Fira Code', monospace;
        }
        .form-group { margin-bottom: 16px; }
        .form-label {
            display: block;
            font-family: 'Fira Code', monospace;
            font-size: 11px;
            color: #d884ff;
            font-weight: 700;
            margin-bottom: 6px;
            letter-spacing: .5px;
        }
        .input-group { position: relative; }
        .input-prefix {
            position: absolute;
            left: 16px; top: 50%;
            transform: translateY(-50%);
            font-family: 'Fira Code', monospace;
            font-size: 15px;
            color: #00f3ff;
            font-weight: bold;
            pointer-events: none;
        }
        input[type='text'], input[type='password'] {
            width: 100%;
            padding: 13px 14px 13px 44px;
            background: rgba(28,10,56,0.95);
            border: 1.5px solid rgba(216,132,255,0.35);
            border-radius: 12px;
            font-family: 'Plus Jakarta Sans', sans-serif;
            font-size: 13.5px;
            color: #fff;
            outline: none;
            transition: .3s;
        }
        input[type='text']:focus, input[type='password']:focus {
            border-color: #ff007f;
            box-shadow: 0 0 20px rgba(255,0,127,.45);
        }
        input::placeholder { color: rgba(255,255,255,.35); }
        .btn-register {
            width: 100%;
            padding: 14px;
            background: linear-gradient(135deg, #d884ff 0%, #ff007f 100%);
            border: none;
            border-radius: 12px;
            font-family: 'Fira Code', monospace;
            font-size: 13px;
            font-weight: 800;
            color: #fff;
            letter-spacing: 1.5px;
            text-transform: uppercase;
            cursor: pointer;
            transition: .3s;
            box-shadow: 0 0 28px rgba(216,132,255,.5);
            margin-top: 6px;
            margin-bottom: 16px;
        }
        .btn-register:hover {
            transform: translateY(-2px);
            box-shadow: 0 0 40px rgba(255,0,127,.8);
            filter: brightness(1.1);
        }
        .error-box {
            background: rgba(255,0,80,.18);
            border: 1px solid #ff0055;
            color: #ff6688;
            padding: 12px;
            border-radius: 10px;
            font-family: 'Fira Code', monospace;
            font-size: 11.5px;
            margin-bottom: 18px;
            text-align: center;
        }
        .ok-box {
            background: rgba(0,255,136,.12);
            border: 1px solid #00ff88;
            color: #00ff88;
            padding: 12px;
            border-radius: 10px;
            font-family: 'Fira Code', monospace;
            font-size: 11.5px;
            margin-bottom: 18px;
            text-align: center;
        }
        .info-box {
            background: rgba(0,243,255,.08);
            border: 1px dashed rgba(0,243,255,.35);
            border-radius: 14px;
            padding: 14px 16px;
            font-family: 'Fira Code', monospace;
            font-size: 11px;
            color: #a8d8f0;
            margin-bottom: 18px;
            line-height: 1.6;
        }
        .info-box b { color: #00f3ff; }
        .divider {
            border: none;
            border-top: 1px dashed rgba(216,132,255,.25);
            margin: 18px 0;
        }
        .back-link {
            display: block;
            text-align: center;
            font-family: 'Fira Code', monospace;
            font-size: 11.5px;
            color: #00f3ff;
            text-decoration: none;
            transition: .2s;
        }
        .back-link:hover { color: #ff80df; text-decoration: underline; }
    </style>
</head>
<body>
<canvas id="canvas"></canvas>

<div class="terminal-container">
    <div class="card">

        <div class="header-tag">
            <span><span class="status-dot"></span>UPLA // NUEVO REGISTRO</span>
            <span>PORT: 8080</span>
        </div>

        <div class="logo-box">
            <img src="<%= ctx %>/IMG/image.png" alt="Logo UPLA"
                 onerror="this.src='https://upload.wikimedia.org/wikipedia/commons/thumb/e/e0/Logo_Universidad_Peruana_Los_Andes.png/640px-Logo_Universidad_Peruana_Los_Andes.png'">
        </div>

        <div class="title-box">
            <h1>REGISTRO DE USUARIO</h1>
            <p>Facultad de Ingenier&iacute;a &bull; EPISC 2026-I</p>
        </div>

        <%-- Mensajes de estado --%>
        <% if ("duplicado".equals(error)) { %>
            <div class="error-box">&#9888;&#65039; ESE CÓDIGO YA ESTÁ REGISTRADO EN EL SISTEMA. INTENTA CON OTRO.</div>
        <% } else if ("campos".equals(error)) { %>
            <div class="error-box">&#9888;&#65039; TODOS LOS CAMPOS SON OBLIGATORIOS. COMPLETA EL FORMULARIO.</div>
        <% } else if (error != null) { %>
            <div class="error-box">&#9888;&#65039; ERROR AL REGISTRAR. INTENTA NUEVAMENTE.</div>
        <% } %>
        <% if ("1".equals(ok)) { %>
            <div class="ok-box">&#10003; REGISTRO EXITOSO. AHORA PUEDES INICIAR SESIÓN CON TU CÓDIGO.</div>
        <% } %>

        <%-- Información --%>
        <div class="info-box">
            &#128274; <b>Acceso institucional:</b><br>
            Ingresa el código que te asignó tu institución.<br>
            Ejemplo: <b>EST2026</b>, tu DNI o código universitario.
        </div>

        <%-- Formulario --%>
        <form action="<%= ctx %>/registro" method="POST">
            <div class="form-group">
                <label class="form-label">CÓDIGO O DNI INSTITUCIONAL:</label>
                <div class="input-group">
                    <span class="input-prefix">&gt;_</span>
                    <input type="text" name="codigo"
                           placeholder="Ej: EST2026 o tu código UPLA"
                           required autofocus autocomplete="off"
                           maxlength="60">
                </div>
            </div>

            <div class="form-group">
                <label class="form-label">NOMBRE Y APELLIDOS COMPLETOS:</label>
                <div class="input-group">
                    <span class="input-prefix">&#128100;</span>
                    <input type="text" name="nombre"
                           placeholder="Ej: Juan Pérez Morales"
                           required autocomplete="off"
                           maxlength="150">
                </div>
            </div>

            <div class="form-group">
                <label class="form-label">CORREO INSTITUCIONAL (OPCIONAL):</label>
                <div class="input-group">
                    <span class="input-prefix">&#9993;</span>
                    <input type="text" name="correo"
                           placeholder="Ej: estudiante@upla.edu.pe"
                           autocomplete="off"
                           maxlength="150">
                </div>
            </div>

            <button type="submit" class="btn-register">&#9889; CREAR CUENTA Y ACCEDER</button>
        </form>

        <hr class="divider">
        <a href="<%= ctx %>/login" class="back-link">&#8592; ¿Ya tienes c&oacute;digo? Iniciar Sesi&oacute;n</a>

    </div>
</div>

<script>
    const canvas = document.getElementById('canvas'),
          ctx_c  = canvas.getContext('2d');
    let w = canvas.width  = window.innerWidth,
        h = canvas.height = window.innerHeight;
    window.onresize = () => {
        w = canvas.width  = window.innerWidth;
        h = canvas.height = window.innerHeight;
    };

    /* Partículas de fondo */
    const parts = [];
    for (let i = 0; i < 55; i++) {
        parts.push({
            x: Math.random() * w, y: Math.random() * h,
            vx: (Math.random() - .5) * .8,
            vy: (Math.random() - .5) * .8,
            r: Math.random() * 2 + 1.2
        });
    }

    /* Rastro del mouse */
    const trail = [];
    let mouse = { x: -1000, y: -1000 };
    window.addEventListener('mousemove', e => {
        const dx = e.clientX - mouse.x,
              dy = e.clientY - mouse.y,
              speed = Math.hypot(dx, dy);
        mouse.x = e.clientX; mouse.y = e.clientY;
        for (let i = 0; i < Math.min(Math.floor(speed / 4) + 2, 7); i++) {
            trail.push({
                x: mouse.x + (Math.random() - .5) * 5,
                y: mouse.y + (Math.random() - .5) * 5,
                vx: -dx * .1 + (Math.random() - .5) * 2,
                vy: -dy * .1 + (Math.random() - .5) * 2,
                r: Math.random() * 3 + 1,
                alpha: 1,
                decay: Math.random() * .03 + .02,
                color: Math.random() > .5 ? '#ff007f' : '#d884ff'
            });
        }
    });

    function loop() {
        ctx_c.clearRect(0, 0, w, h);

        /* Partículas + conexiones */
        for (let i = 0; i < parts.length; i++) {
            const p = parts[i];
            p.x += p.vx; p.y += p.vy;
            if (p.x < 0 || p.x > w) p.vx *= -1;
            if (p.y < 0 || p.y > h) p.vy *= -1;
            ctx_c.beginPath();
            ctx_c.arc(p.x, p.y, p.r, 0, Math.PI * 2);
            ctx_c.fillStyle = 'rgba(216,132,255,0.65)';
            ctx_c.fill();
            for (let j = i + 1; j < parts.length; j++) {
                const p2 = parts[j],
                      d  = Math.hypot(p.x - p2.x, p.y - p2.y);
                if (d < 110) {
                    ctx_c.beginPath();
                    ctx_c.moveTo(p.x, p.y); ctx_c.lineTo(p2.x, p2.y);
                    ctx_c.strokeStyle = `rgba(216,132,255,${.3 * (1 - d / 110)})`;
                    ctx_c.lineWidth = .8;
                    ctx_c.stroke();
                }
            }
        }

        /* Rastro del mouse */
        for (let i = trail.length - 1; i >= 0; i--) {
            const p = trail[i];
            p.x += p.vx; p.y += p.vy;
            p.alpha -= p.decay; p.r *= .96;
            if (p.alpha <= 0) { trail.splice(i, 1); continue; }
            ctx_c.save();
            ctx_c.shadowBlur = 12; ctx_c.shadowColor = p.color;
            ctx_c.fillStyle = p.color; ctx_c.globalAlpha = p.alpha;
            ctx_c.beginPath(); ctx_c.arc(p.x, p.y, p.r, 0, Math.PI * 2);
            ctx_c.fill(); ctx_c.restore();
        }
        requestAnimationFrame(loop);
    }
    loop();
</script>
</body>
</html>
