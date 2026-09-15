<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%
    /* Si ya hay sesión activa, redirigir al portafolio */
    if (session != null && session.getAttribute("usuario") != null) {
        response.sendRedirect(request.getContextPath() + "/portafolio");
        return;
    }
    String error = request.getParameter("error");
    String ok    = request.getParameter("ok");
    String ctx   = request.getContextPath();
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
    <title>ACCESO PRIVADO // UPLA — Arquitectura de Software</title>
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
            max-width: 450px;
        }
        .card {
            background: rgba(18,6,36,0.88);
            backdrop-filter: blur(25px);
            border: 1.5px solid rgba(216,132,255,0.45);
            border-radius: 26px;
            padding: 42px 32px;
            box-shadow: 0 0 55px rgba(216,132,255,0.35), 0 20px 60px rgba(0,0,0,0.85);
            animation: floatCard 6s ease-in-out infinite;
        }
        @keyframes floatCard {
            0%, 100% { transform: translateY(0); }
            50%       { transform: translateY(-7px); }
        }
        .header-tag {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 22px;
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
            background: #00ff88;
            border-radius: 50%;
            box-shadow: 0 0 10px #00ff88;
            margin-right: 6px;
            animation: pulseDot 2s infinite;
        }
        @keyframes pulseDot {
            0%, 100% { opacity: 1; transform: scale(1); }
            50%       { opacity: .4; transform: scale(.8); }
        }
        .logo-box { text-align: center; margin-bottom: 16px; }
        .logo-box img {
            height: 80px;
            filter: drop-shadow(0 0 20px rgba(216,132,255,0.85));
            transition: .3s;
        }
        .logo-box img:hover { transform: scale(1.06); }
        .title-box { text-align: center; margin-bottom: 26px; }
        .title-box h1 {
            font-family: 'Plus Jakarta Sans', sans-serif;
            font-size: 22px;
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
        .input-group { position: relative; margin-bottom: 20px; }
        .input-prefix {
            position: absolute;
            left: 16px; top: 50%;
            transform: translateY(-50%);
            font-family: 'Fira Code', monospace;
            font-size: 16px;
            color: #00f3ff;
            font-weight: bold;
            pointer-events: none;
        }
        .input-pass, input[type='password'] {
            width: 100%;
            padding: 15px 50px 15px 48px;
            background: rgba(28,10,56,0.95);
            border: 1.5px solid rgba(216,132,255,0.35);
            border-radius: 14px;
            font-family: 'Fira Code', monospace;
            font-size: 15px;
            color: #00f3ff;
            outline: none;
            transition: .3s;
            letter-spacing: 2.5px;
            font-weight: 700;
        }
        .input-pass:focus, input[type='password']:focus {
            border-color: #ff007f;
            box-shadow: 0 0 22px rgba(255,0,127,.5);
        }
        .toggle-pass-btn {
            position: absolute;
            right: 14px;
            top: 50%;
            transform: translateY(-50%);
            background: transparent;
            border: none;
            color: #d884ff;
            font-size: 18px;
            cursor: pointer;
            padding: 6px;
            display: flex;
            align-items: center;
            justify-content: center;
            transition: .25s;
            filter: drop-shadow(0 0 6px rgba(216,132,255,0.6));
            border-radius: 8px;
        }
        .toggle-pass-btn:hover {
            color: #00f3ff;
            transform: translateY(-50%) scale(1.18);
            filter: drop-shadow(0 0 12px #00f3ff);
            background: rgba(255,255,255,0.06);
        }
        .btn-login {
            width: 100%;
            padding: 15px;
            background: linear-gradient(135deg, #d884ff 0%, #ff007f 100%);
            border: none;
            border-radius: 14px;
            font-family: 'Fira Code', monospace;
            font-size: 13.5px;
            font-weight: 800;
            color: #fff;
            letter-spacing: 1.5px;
            text-transform: uppercase;
            cursor: pointer;
            transition: .3s;
            box-shadow: 0 0 28px rgba(216,132,255,.5);
            margin-bottom: 16px;
        }
        .btn-login:hover {
            transform: translateY(-2px);
            box-shadow: 0 0 40px rgba(255,0,127,.8);
            filter: brightness(1.1);
        }
        .btn-sin-pass {
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 9px;
            width: 100%;
            padding: 15px;
            background: rgba(0, 243, 255, 0.12);
            border: 1.5px solid #00f3ff;
            border-radius: 14px;
            font-family: 'Fira Code', monospace;
            font-size: 13px;
            font-weight: 800;
            color: #00f3ff;
            letter-spacing: 1.2px;
            text-transform: uppercase;
            text-decoration: none;
            cursor: pointer;
            transition: .3s;
            box-shadow: 0 0 22px rgba(0, 243, 255, 0.35);
            margin-bottom: 20px;
        }
        .btn-sin-pass:hover {
            background: #00f3ff;
            color: #05020c;
            box-shadow: 0 0 38px rgba(0, 243, 255, 0.85);
            transform: translateY(-2px);
            filter: brightness(1.15);
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
        .lock-box {
            background: rgba(255,255,255,.03);
            border: 1px dashed rgba(216,132,255,.28);
            border-radius: 14px;
            padding: 14px;
            text-align: center;
            font-family: 'Fira Code', monospace;
            font-size: 11px;
            color: #d6c0f2;
            margin-bottom: 18px;
        }
        .telemetry {
            border-top: 1px dashed rgba(216,132,255,.25);
            padding-top: 14px;
            display: flex;
            justify-content: space-between;
            font-family: 'Fira Code', monospace;
            font-size: 10.5px;
            color: #bba2e2;
        }
    </style>
</head>
<body>
<canvas id="canvas"></canvas>

<div class="terminal-container">
    <div class="card">

        <div class="header-tag">
            <span><span class="status-dot"></span>UPLA // SYS_SECURE</span>
            <span>PORT: 8080</span>
        </div>

        <div class="logo-box">
            <img src="<%= ctx %>/IMG/image.png" alt="Logo UPLA"
                 onerror="this.src='https://upload.wikimedia.org/wikipedia/commons/thumb/e/e0/Logo_Universidad_Peruana_Los_Andes.png/640px-Logo_Universidad_Peruana_Los_Andes.png'">
        </div>

        <div class="title-box">
            <h1>ARQUITECTURA DE SOFTWARE</h1>
            <p>Acceso Alumna Titular &bull; Panel de Administraci&oacute;n</p>
        </div>

        <% if (error != null) { %>
        <div class="error-box">&#9888;&#65039; ACCESO DENEGADO // CLAVE NO REGISTRADA EN EL SISTEMA</div>
        <% } %>
        <% if ("1".equals(ok)) { %>
        <div style="background:rgba(0,255,136,.12);border:1px solid #00ff88;color:#00ff88;padding:12px;border-radius:10px;font-family:'Fira Code',monospace;font-size:11.5px;margin-bottom:18px;text-align:center;">
            &#10003; REGISTRO EXITOSO &bull; AHORA INGRESA TU CÓDIGO PARA ACCEDER
        </div>
        <% } %>

        <form action="<%= ctx %>/login" method="POST">
            <div class="input-group">
                <span class="input-prefix">&gt;_</span>
                <input type="password" name="codigo" id="passInput" class="input-pass"
                       placeholder="Ingresa clave alumna..."
                       autofocus autocomplete="off">
                <button type="button" class="toggle-pass-btn" id="togglePassBtn" onclick="togglePass()" title="Mostrar u ocultar contraseña">
                    <span id="eyeIcon">👁️</span>
                </button>
            </div>
            <button type="submit" class="btn-login">&#9889; ENTRAR COMO ALUMNA</button>
        </form>



        <div class="telemetry">
            <span>SISTEMA DE PERSISTENCIA ACTIVO</span>
            <span style="color:#00ff88;">&#9679; SERVIDOR ONLINE</span>
        </div>
        <div style="border-top:1px dashed rgba(216,132,255,.2);margin-top:16px;padding-top:14px;text-align:center;">
            <a href="<%= ctx %>/registro"
               style="font-family:'Fira Code',monospace;font-size:11.5px;color:#d884ff;text-decoration:none;transition:.2s;"
               onmouseover="this.style.color='#00f3ff'" onmouseout="this.style.color='#d884ff'">
                &#43; ¿Primera vez? Crear cuenta &rarr;
            </a>
        </div>

    </div>
</div>

<script>
    const canvas = document.getElementById('canvas'),
          ctx    = canvas.getContext('2d');
    let w = canvas.width  = window.innerWidth,
        h = canvas.height = window.innerHeight;

    window.onresize = () => {
        w = canvas.width  = window.innerWidth;
        h = canvas.height = window.innerHeight;
    };

    /* Partículas de fondo */
    const parts = [];
    for (let i = 0; i < 65; i++) {
        parts.push({
            x: Math.random() * w, y: Math.random() * h,
            vx: (Math.random() - .5) * .8,
            vy: (Math.random() - .5) * .8,
            r: 2.2
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
        for (let i = 0; i < Math.min(Math.floor(speed / 4) + 2, 8); i++) {
            trail.push({
                x: mouse.x + (Math.random() - .5) * 6,
                y: mouse.y + (Math.random() - .5) * 6,
                vx: -dx * .1 + (Math.random() - .5) * 2,
                vy: -dy * .1 + (Math.random() - .5) * 2,
                r: Math.random() * 3 + 1.2,
                alpha: 1,
                decay: Math.random() * .03 + .02,
                color: Math.random() > .5 ? '#00f3ff' : '#d884ff'
            });
        }
    });

    function loop() {
        ctx.clearRect(0, 0, w, h);

        /* Partículas + líneas */
        for (let i = 0; i < parts.length; i++) {
            const p = parts[i];
            p.x += p.vx; p.y += p.vy;
            if (p.x < 0 || p.x > w) p.vx *= -1;
            if (p.y < 0 || p.y > h) p.vy *= -1;
            ctx.beginPath();
            ctx.arc(p.x, p.y, p.r, 0, Math.PI * 2);
            ctx.fillStyle = 'rgba(216,132,255,0.7)';
            ctx.fill();
            for (let j = i + 1; j < parts.length; j++) {
                const p2 = parts[j],
                      d  = Math.hypot(p.x - p2.x, p.y - p2.y);
                if (d < 120) {
                    ctx.beginPath();
                    ctx.moveTo(p.x, p.y);
                    ctx.lineTo(p2.x, p2.y);
                    ctx.strokeStyle = `rgba(216,132,255,${.35 * (1 - d / 120)})`;
                    ctx.lineWidth = .9;
                    ctx.stroke();
                }
            }
        }

        /* Rastro del mouse */
        for (let i = trail.length - 1; i >= 0; i--) {
            const p = trail[i];
            p.x += p.vx; p.y += p.vy;
            p.alpha -= p.decay; p.r *= .96;
            if (p.alpha <= 0) { trail.splice(i, 1); continue; }
            ctx.save();
            ctx.shadowBlur = 12; ctx.shadowColor = p.color;
            ctx.fillStyle = p.color; ctx.globalAlpha = p.alpha;
            ctx.beginPath(); ctx.arc(p.x, p.y, p.r, 0, Math.PI * 2);
            ctx.fill(); ctx.restore();
        }
        requestAnimationFrame(loop);
    }
    loop();

    function togglePass() {
        const inp = document.getElementById('passInput');
        const icon = document.getElementById('eyeIcon');
        if (!inp) return;
        if (inp.type === 'password') {
            inp.type = 'text';
            icon.innerText = '🙈';
        } else {
            inp.type = 'password';
            icon.innerText = '👁️';
        }
        inp.focus();
    }
</script>
</body>
</html>
