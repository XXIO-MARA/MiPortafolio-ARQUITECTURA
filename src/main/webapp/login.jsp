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
    <title>ACCESO AL PORTAFOLIO // UPLA — Arquitectura de Software</title>
    <link href="https://fonts.googleapis.com/css2?family=Fira+Code:wght@400;600;700;800&family=Plus+Jakarta+Sans:wght@400;600;800;900&display=swap" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css" rel="stylesheet">
    <script>
        /* Aplicación ultra rápida de tema antes del render para evitar parpadeo */
        (function() {
            var savedTheme = localStorage.getItem('portfolio_theme') || 'cyber';
            document.documentElement.setAttribute('data-theme', savedTheme);
        })();
    </script>
    <style>
        :root, [data-theme="cyber"] {
            --bg-main: #05020c;
            --bg-card: rgba(18, 6, 36, 0.88);
            --bg-card-subtle: rgba(28, 10, 56, 0.95);
            --border-color: rgba(216, 132, 255, 0.45);
            --border-accent: #00f3ff;
            --text-primary: #f5edff;
            --text-secondary: #d0b8ee;
            --accent-cyan: #00f3ff;
            --accent-pink: #ff007f;
            --accent-purple: #d884ff;
            --card-shadow: 0 0 55px rgba(216, 132, 255, 0.35), 0 20px 60px rgba(0, 0, 0, 0.85);
        }

        [data-theme="dark"] {
            --bg-main: #0b0f19;
            --bg-card: rgba(17, 24, 39, 0.92);
            --bg-card-subtle: rgba(30, 41, 59, 0.95);
            --border-color: rgba(99, 102, 241, 0.4);
            --border-accent: #38bdf8;
            --text-primary: #f8fafc;
            --text-secondary: #94a3b8;
            --accent-cyan: #38bdf8;
            --accent-pink: #6366f1;
            --accent-purple: #818cf8;
            --card-shadow: 0 0 55px rgba(59, 130, 246, 0.3), 0 20px 60px rgba(0, 0, 0, 0.85);
        }

        [data-theme="light"] {
            --bg-main: #f1f5f9;
            --bg-card: rgba(255, 255, 255, 0.97);
            --bg-card-subtle: #f8fafc;
            --border-color: #cbd5e1;
            --border-accent: #2563eb;
            --text-primary: #0f172a;
            --text-secondary: #475569;
            --accent-cyan: #0284c7;
            --accent-pink: #d946ef;
            --accent-purple: #7c3aed;
            --card-shadow: 0 10px 40px rgba(0, 0, 0, 0.12);
        }

        [data-theme="matrix"] {
            --bg-main: #040d08;
            --bg-card: rgba(6, 26, 14, 0.92);
            --bg-card-subtle: rgba(8, 38, 20, 0.95);
            --border-color: rgba(16, 185, 129, 0.45);
            --border-accent: #00ff88;
            --text-primary: #ecfdf5;
            --text-secondary: #6ee7b7;
            --accent-cyan: #00ff88;
            --accent-pink: #10b981;
            --accent-purple: #34d399;
            --card-shadow: 0 0 55px rgba(0, 255, 136, 0.3), 0 20px 60px rgba(0, 0, 0, 0.85);
        }

        [data-theme="synthwave"] {
            --bg-main: #180928;
            --bg-card: rgba(38, 14, 60, 0.92);
            --bg-card-subtle: rgba(48, 16, 76, 0.95);
            --border-color: rgba(255, 122, 0, 0.45);
            --border-accent: #ffea00;
            --text-primary: #fff7ed;
            --text-secondary: #fed7aa;
            --accent-cyan: #ffea00;
            --accent-pink: #ff007f;
            --accent-purple: #ff7a00;
            --card-shadow: 0 0 55px rgba(255, 122, 0, 0.35), 0 20px 60px rgba(0, 0, 0, 0.85);
        }

        * { box-sizing: border-box; margin: 0; padding: 0; }
        body {
            background: var(--bg-main);
            font-family: 'Plus Jakarta Sans', sans-serif;
            color: var(--text-primary);
            min-height: 100vh;
            display: flex;
            justify-content: center;
            align-items: center;
            position: relative;
            overflow-x: hidden;
            padding: 20px;
            transition: background .3s ease, color .3s ease;
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
            max-width: 460px;
        }
        .card {
            background: var(--bg-card);
            backdrop-filter: blur(25px);
            border: 1.5px solid var(--border-color);
            border-radius: 26px;
            padding: 40px 32px;
            box-shadow: var(--card-shadow);
            animation: floatCard 6s ease-in-out infinite;
            transition: all .3s ease;
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
            color: var(--accent-cyan);
            text-transform: uppercase;
            border-bottom: 1px dashed var(--border-color);
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
            filter: drop-shadow(0 0 20px var(--border-accent));
            transition: .3s;
        }
        .logo-box img:hover { transform: scale(1.06); }
        .title-box { text-align: center; margin-bottom: 24px; }
        .title-box h1 {
            font-family: 'Plus Jakarta Sans', sans-serif;
            font-size: 22px;
            font-weight: 900;
            background: linear-gradient(135deg, var(--text-primary) 0%, var(--accent-pink) 40%, var(--accent-cyan) 100%);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            text-transform: uppercase;
            margin-bottom: 4px;
            filter: drop-shadow(0 0 14px rgba(216,132,255,.6));
        }
        .title-box p {
            font-size: 11.5px;
            color: var(--text-secondary);
            font-family: 'Fira Code', monospace;
        }
        .input-group { position: relative; margin-bottom: 20px; }
        .input-prefix {
            position: absolute;
            left: 16px; top: 50%;
            transform: translateY(-50%);
            font-family: 'Fira Code', monospace;
            font-size: 16px;
            color: var(--accent-cyan);
            font-weight: bold;
            pointer-events: none;
        }
        input[type='text'], input[type='password'] {
            width: 100%;
            padding: 15px 15px 15px 48px;
            background: var(--bg-card-subtle);
            border: 1.5px solid var(--border-color);
            border-radius: 14px;
            font-family: 'Fira Code', monospace;
            font-size: 14px;
            color: var(--accent-cyan);
            outline: none;
            transition: .3s;
            font-weight: 700;
        }
        input[type='text']:focus, input[type='password']:focus {
            border-color: var(--accent-pink);
            box-shadow: 0 0 22px rgba(255,0,127,.5);
        }
        .btn-login {
            width: 100%;
            padding: 15px;
            background: linear-gradient(135deg, var(--accent-purple) 0%, var(--accent-pink) 100%);
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
            margin-bottom: 18px;
        }
        .btn-login:hover {
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
        .lock-box {
            background: rgba(255,255,255,.03);
            border: 1px dashed var(--border-color);
            border-radius: 14px;
            padding: 14px;
            text-align: center;
            font-family: 'Fira Code', monospace;
            font-size: 11px;
            color: var(--text-secondary);
            margin-bottom: 18px;
        }
        .telemetry {
            border-top: 1px dashed var(--border-color);
            padding-top: 14px;
            display: flex;
            justify-content: space-between;
            font-family: 'Fira Code', monospace;
            font-size: 10.5px;
            color: var(--text-secondary);
        }

        /* ── CONTROLES FLOTANTES EN LOGIN (TEMAS Y MÚSICA) ── */
        .login-floating-bar {
            position: fixed;
            top: 20px;
            right: 24px;
            z-index: 100;
            display: flex;
            align-items: center;
            gap: 10px;
        }
        .btn-theme-trigger, .btn-music-pill {
            background: var(--bg-card);
            border: 1.5px solid var(--border-color);
            color: var(--text-primary);
            padding: 8px 14px;
            border-radius: 12px;
            font-family: 'Fira Code', monospace;
            font-size: 11px;
            font-weight: 800;
            cursor: pointer;
            transition: all .25s ease;
            display: inline-flex;
            align-items: center;
            gap: 7px;
            white-space: nowrap;
            backdrop-filter: blur(15px);
            box-shadow: 0 4px 16px rgba(0,0,0,0.3);
        }
        .btn-theme-trigger:hover, .btn-music-pill:hover {
            border-color: var(--accent-cyan);
            box-shadow: 0 0 15px var(--accent-cyan);
            transform: translateY(-1px);
        }
        .btn-music-pill.playing {
            border-color: var(--accent-cyan);
            background: rgba(0, 243, 255, 0.15);
            color: var(--accent-cyan);
        }
        .music-bars-eq {
            display: flex;
            align-items: flex-end;
            gap: 2px;
            height: 12px;
            width: 12px;
        }
        .eq-bar {
            width: 2px;
            background: var(--text-secondary);
            border-radius: 2px;
            height: 3px;
        }
        .btn-music-pill.playing .eq-bar {
            background: var(--accent-cyan);
            animation: bounceBar 0.8s ease-in-out infinite alternate;
        }
        .btn-music-pill.playing .bar-1 { animation-delay: 0.0s; height: 8px; }
        .btn-music-pill.playing .bar-2 { animation-delay: 0.2s; height: 12px; }
        .btn-music-pill.playing .bar-3 { animation-delay: 0.4s; height: 6px; }
        .btn-music-pill.playing .bar-4 { animation-delay: 0.1s; height: 10px; }
        @keyframes bounceBar {
            0%   { height: 3px; }
            100% { height: 12px; }
        }
        .theme-switcher-container { position: relative; }
        .theme-dropdown-menu {
            position: absolute;
            top: calc(100% + 8px);
            right: 0;
            background: var(--bg-card);
            border: 1.5px solid var(--border-color);
            border-radius: 18px;
            padding: 8px;
            min-width: 230px;
            box-shadow: var(--card-shadow);
            z-index: 10001;
            display: none;
            flex-direction: column;
            gap: 4px;
            backdrop-filter: blur(25px);
        }
        .theme-dropdown-menu.show { display: flex; }
        .theme-dropdown-header {
            font-family: 'Fira Code', monospace;
            font-size: 10px;
            font-weight: 800;
            color: var(--accent-cyan);
            padding: 6px 10px;
            border-bottom: 1px solid var(--border-color);
            letter-spacing: 1px;
        }
        .theme-opt-btn {
            background: transparent;
            border: 1px solid transparent;
            border-radius: 10px;
            padding: 7px 10px;
            cursor: pointer;
            display: flex;
            align-items: center;
            gap: 10px;
            text-align: left;
            transition: all .2s ease;
            color: var(--text-primary);
            width: 100%;
        }
        .theme-opt-btn:hover {
            background: rgba(255, 255, 255, 0.08);
            border-color: var(--border-color);
        }
        .theme-opt-btn.active {
            background: rgba(0, 243, 255, 0.12);
            border-color: var(--accent-cyan);
        }
        .theme-dot {
            width: 16px;
            height: 16px;
            border-radius: 50%;
            flex-shrink: 0;
        }
        .theme-info {
            display: flex;
            flex-direction: column;
            flex: 1;
        }
        .theme-name {
            font-size: 11.5px;
            font-weight: 800;
            color: var(--text-primary);
        }
        .theme-desc {
            font-size: 9px;
            font-family: 'Fira Code', monospace;
            color: var(--text-secondary);
        }
        .theme-check {
            font-size: 10px;
            color: var(--accent-cyan);
            display: none;
        }
        .theme-opt-btn.active .theme-check {
            display: inline-block;
        }

        /* Adaptación clara para login */
        [data-theme="light"] .card { background: #ffffff !important; border-color: #cbd5e1 !important; color: #0f172a !important; }
        [data-theme="light"] input[type='text'], [data-theme="light"] input[type='password'] { background: #f8fafc !important; color: #0f172a !important; border-color: #cbd5e1 !important; }
        [data-theme="light"] .lock-box { background: #f8fafc !important; border-color: #cbd5e1 !important; color: #475569 !important; }
        [data-theme="light"] .btn-theme-trigger, [data-theme="light"] .btn-music-pill { background: #ffffff !important; color: #0f172a !important; border-color: #cbd5e1 !important; }
        [data-theme="light"] .theme-dropdown-menu { background: #ffffff !important; border-color: #cbd5e1 !important; }
    </style>
</head>
<body>
<canvas id="canvas"></canvas>
<audio id="bgMusicPlayer" src="<%= ctx %>/cyber_music.wav" loop preload="auto"></audio>

<!-- CONTROLES FLOTANTES SUPERIORES (TEMAS Y MÚSICA) -->
<div class="login-floating-bar">
    <button type="button" class="btn-music-pill" id="musicPillBtn" onclick="toggleMusic(event)" title="Reproducir música ambiental">
        <div class="music-bars-eq" id="musicEqBars">
            <span class="eq-bar bar-1"></span>
            <span class="eq-bar bar-2"></span>
            <span class="eq-bar bar-3"></span>
            <span class="eq-bar bar-4"></span>
        </div>
        <i class="fas fa-play" id="musicPlayIcon"></i>
        <span id="musicBtnLabel">MÚSICA</span>
    </button>

    <div class="theme-switcher-container">
        <button type="button" class="btn-theme-trigger" id="themeBtn" onclick="toggleThemeMenu(event)" title="Cambiar tema">
            <i class="fas fa-palette" style="color:var(--accent-cyan);"></i>
            <span>TEMAS</span>
            <i class="fas fa-chevron-down" style="font-size:9px;"></i>
        </button>
        <div class="theme-dropdown-menu" id="themeDropdownMenu">
            <div class="theme-dropdown-header">// SELECCIONAR TEMA</div>
            <button type="button" class="theme-opt-btn" data-theme-val="cyber" onclick="setTheme('cyber')">
                <span class="theme-dot" style="background: linear-gradient(135deg, #00f3ff, #ff007f);"></span>
                <div class="theme-info">
                    <span class="theme-name">🌌 Cyber Neón</span>
                    <span class="theme-desc">Futurista y cósmico (Original)</span>
                </div>
                <i class="fas fa-check theme-check"></i>
            </button>
            <button type="button" class="theme-opt-btn" data-theme-val="dark" onclick="setTheme('dark')">
                <span class="theme-dot" style="background: linear-gradient(135deg, #3b82f6, #6366f1);"></span>
                <div class="theme-info">
                    <span class="theme-name">🌑 Eclipse Dark</span>
                    <span class="theme-desc">Azul zafiro & obsidiana pro</span>
                </div>
                <i class="fas fa-check theme-check"></i>
            </button>
            <button type="button" class="theme-opt-btn" data-theme-val="light" onclick="setTheme('light')">
                <span class="theme-dot" style="background: linear-gradient(135deg, #ffffff, #2563eb); border:1px solid #cbd5e1;"></span>
                <div class="theme-info">
                    <span class="theme-name">☀️ Modo Claro</span>
                    <span class="theme-desc">Blanco académico minimalista</span>
                </div>
                <i class="fas fa-check theme-check"></i>
            </button>
            <button type="button" class="theme-opt-btn" data-theme-val="matrix" onclick="setTheme('matrix')">
                <span class="theme-dot" style="background: linear-gradient(135deg, #00ff88, #10b981);"></span>
                <div class="theme-info">
                    <span class="theme-name">📟 Emerald Matrix</span>
                    <span class="theme-desc">Terminal hacker verde neón</span>
                </div>
                <i class="fas fa-check theme-check"></i>
            </button>
            <button type="button" class="theme-opt-btn" data-theme-val="synthwave" onclick="setTheme('synthwave')">
                <span class="theme-dot" style="background: linear-gradient(135deg, #ff007f, #ff7a00);"></span>
                <div class="theme-info">
                    <span class="theme-name">🌅 Sunset Synthwave</span>
                    <span class="theme-desc">Atardecer 80s cálido y violeta</span>
                </div>
                <i class="fas fa-check theme-check"></i>
            </button>
        </div>
    </div>
</div>

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
            <p>Facultad de Ingeniería &bull; EPISC 2026-I</p>
        </div>

        <% if (error != null) { %>
        <div class="error-box">&#9888;&#65039; ACCESO DENEGADO // CLAVE NO REGISTRADA EN EL SISTEMA</div>
        <% } %>
        <% if ("1".equals(ok)) { %>
        <div style="background:rgba(0,255,136,.12);border:1px solid #00ff88;color:#00ff88;padding:12px;border-radius:10px;font-family:'Fira Code',monospace;font-size:11.5px;margin-bottom:18px;text-align:center;">
            &#10003; REGISTRO EXITOSO &bull; AHORA INGRESA TU CÓDIGO PARA ACCEDER
        </div>
        <% } %>

        <form action="<%= ctx %>/login" method="POST" id="loginForm">
            <div class="input-group">
                <span class="input-prefix">&gt;_</span>
                <input type="text" name="codigo" id="inputCodigo"
                       placeholder="Código o Celular (ej: ADMIN949163067)"
                       required autofocus autocomplete="off">
            </div>
            <button type="submit" class="btn-login">&#9889; AUTENTICAR Y ACCEDER</button>
        </form>

        <!-- ACCESO RÁPIDO PARA ALUMNA TITULAR (FLOR XIOMARA) -->
        <button type="button" onclick="loginDirectoAlumna()"
                style="width:100%;padding:14px;margin-bottom:18px;background:rgba(0,243,255,0.12);border:1.8px solid var(--accent-cyan);border-radius:14px;font-family:'Fira Code',monospace;font-size:12px;font-weight:800;color:var(--accent-cyan);cursor:pointer;box-shadow:0 0 20px rgba(0,243,255,0.3);transition:.3s;display:flex;align-items:center;justify-content:center;gap:8px;"
                onmouseover="this.style.background='rgba(0,243,255,0.25)';this.style.transform='translateY(-2px)'"
                onmouseout="this.style.background='rgba(0,243,255,0.12)';this.style.transform='none'">
            &#9889; ENTRAR COMO ALUMNA FLOR XIOMARA (1 CLIC)
        </button>

        <div class="lock-box">
            &#128274; <b>ACCESO CON PRIVILEGIOS DE MODIFICACIÓN</b><br>
            <span style="color:var(--accent-cyan);font-size:10.5px;">Permite publicar tareas, subir archivos a las 16 semanas y editar perfil.</span><br>
            <span style="color:var(--accent-purple);font-size:10px;margin-top:4px;display:block;">Acepta: <b>ADMIN949163067</b> &bull; Celular: <b>949163067</b> &bull; Código: <b>s01269h</b></span>
        </div>

        <div style="text-align:center;margin-bottom:14px;">
            <a href="<%= ctx %>/visitar"
               style="font-family:'Fira Code',monospace;font-size:11px;color:var(--accent-cyan);text-decoration:none;"
               onmouseover="this.style.textDecoration='underline'" onmouseout="this.style.textDecoration='none'">
                &larr; Volver al Portafolio en Modo Visitante
            </a>
        </div>

        <div class="telemetry">
            <span>SISTEMA DE PERSISTENCIA ACTIVO</span>
            <span style="color:#00ff88;">&#9679; SERVIDOR ONLINE</span>
        </div>
        <div style="border-top:1px dashed var(--border-color);margin-top:16px;padding-top:14px;text-align:center;">
            <a href="<%= ctx %>/registro"
               style="font-family:'Fira Code',monospace;font-size:11.5px;color:var(--accent-purple);text-decoration:none;transition:.2s;"
               onmouseover="this.style.color='var(--accent-cyan)'" onmouseout="this.style.color='var(--accent-purple)'">
                &#43; ¿Primera vez? Crear cuenta &rarr;
            </a>
        </div>

    </div>
</div>

<script>
    /* ── MOTOR DE TEMAS EN LOGIN ────────────────────────── */
    let themeParticlePalette = ['#00f3ff', '#ff007f', '#d884ff'];
    let themeStarColor = 'rgba(216,132,255,';

    function setTheme(theme) {
        if (!theme) theme = 'cyber';
        document.documentElement.setAttribute('data-theme', theme);
        localStorage.setItem('portfolio_theme', theme);

        document.querySelectorAll('.theme-opt-btn').forEach(btn => {
            if (btn.getAttribute('data-theme-val') === theme) {
                btn.classList.add('active');
            } else {
                btn.classList.remove('active');
            }
        });

        actualizarColoresCanvas(theme);
        const menu = document.getElementById('themeDropdownMenu');
        if (menu) menu.classList.remove('show');
    }

    function toggleThemeMenu(e) {
        if (e) e.stopPropagation();
        const menu = document.getElementById('themeDropdownMenu');
        if (menu) menu.classList.toggle('show');
    }

    document.addEventListener('click', (e) => {
        const menu = document.getElementById('themeDropdownMenu');
        const btn = document.getElementById('themeBtn');
        if (menu && menu.classList.contains('show')) {
            if (!menu.contains(e.target) && (!btn || !btn.contains(e.target))) {
                menu.classList.remove('show');
            }
        }
    });

    function actualizarColoresCanvas(theme) {
        if (theme === 'dark') {
            themeParticlePalette = ['#38bdf8', '#6366f1', '#818cf8'];
            themeStarColor = 'rgba(99,102,241,';
        } else if (theme === 'light') {
            themeParticlePalette = ['#2563eb', '#7c3aed', '#0284c7'];
            themeStarColor = 'rgba(37,99,235,';
        } else if (theme === 'matrix') {
            themeParticlePalette = ['#00ff88', '#10b981', '#34d399'];
            themeStarColor = 'rgba(0,255,136,';
        } else if (theme === 'synthwave') {
            themeParticlePalette = ['#ff007f', '#ff7a00', '#ffea00'];
            themeStarColor = 'rgba(255,122,0,';
        } else {
            themeParticlePalette = ['#00f3ff', '#ff007f', '#d884ff'];
            themeStarColor = 'rgba(216,132,255,';
        }
    }

    /* ── MOTOR DE MÚSICA EN LOGIN ───────────────────────── */
    let bgAudio = null;
    let isMusicPlaying = false;

    function initMusicEngine() {
        bgAudio = document.getElementById('bgMusicPlayer');
        if (bgAudio) {
            bgAudio.volume = 0.5;
            bgAudio.addEventListener('play', () => updateMusicUI(true));
            bgAudio.addEventListener('pause', () => updateMusicUI(false));
            bgAudio.addEventListener('ended', () => {
                if (isMusicPlaying) bgAudio.play().catch(() => {});
            });
        }
    }

    function updateMusicUI(playing) {
        isMusicPlaying = playing;
        const pill = document.getElementById('musicPillBtn');
        const icon = document.getElementById('musicPlayIcon');
        const label = document.getElementById('musicBtnLabel');
        if (pill) {
            if (playing) {
                pill.classList.add('playing');
                if (icon) icon.className = 'fas fa-pause';
                if (label) label.innerText = 'PAUSA';
            } else {
                pill.classList.remove('playing');
                if (icon) icon.className = 'fas fa-play';
                if (label) label.innerText = 'MÚSICA';
            }
        }
    }

    function toggleMusic(e) {
        if (e) e.stopPropagation();
        if (!bgAudio) initMusicEngine();

        if (isMusicPlaying) {
            if (bgAudio) bgAudio.pause();
            updateMusicUI(false);
            localStorage.setItem('portfolio_music_enabled', 'false');
        } else {
            if (bgAudio) {
                bgAudio.play().then(() => {
                    updateMusicUI(true);
                }).catch(() => {});
            }
            localStorage.setItem('portfolio_music_enabled', 'true');
        }
    }

    window.addEventListener('click', () => {
        const shouldPlay = localStorage.getItem('portfolio_music_enabled');
        if (shouldPlay === 'true' && !isMusicPlaying) {
            if (!bgAudio) initMusicEngine();
            if (bgAudio) bgAudio.play().then(() => updateMusicUI(true)).catch(() => {});
        }
    }, { once: true });

    /* ── CANVAS DE FONDO ────────────────────────────────── */
    const canvas = document.getElementById('canvas'),
          ctx    = canvas.getContext('2d');
    let w = canvas.width  = window.innerWidth,
        h = canvas.height = window.innerHeight;

    window.onresize = () => {
        w = canvas.width  = window.innerWidth;
        h = canvas.height = window.innerHeight;
    };

    const parts = [];
    for (let i = 0; i < 65; i++) {
        parts.push({
            x: Math.random() * w, y: Math.random() * h,
            vx: (Math.random() - .5) * .8,
            vy: (Math.random() - .5) * .8,
            r: 2.2
        });
    }

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
                color: themeParticlePalette[Math.floor(Math.random() * themeParticlePalette.length)]
            });
        }
    });

    function loop() {
        ctx.clearRect(0, 0, w, h);

        for (let i = 0; i < parts.length; i++) {
            const p = parts[i];
            p.x += p.vx; p.y += p.vy;
            if (p.x < 0 || p.x > w) p.vx *= -1;
            if (p.y < 0 || p.y > h) p.vy *= -1;
            ctx.beginPath();
            ctx.arc(p.x, p.y, p.r, 0, Math.PI * 2);
            ctx.fillStyle = themeStarColor + '0.7)';
            ctx.fill();
            for (let j = i + 1; j < parts.length; j++) {
                const p2 = parts[j],
                      d  = Math.hypot(p.x - p2.x, p.y - p2.y);
                if (d < 120) {
                    ctx.beginPath();
                    ctx.moveTo(p.x, p.y);
                    ctx.lineTo(p2.x, p2.y);
                    ctx.strokeStyle = themeStarColor + (.35 * (1 - d / 120)) + ')';
                    ctx.lineWidth = .9;
                    ctx.stroke();
                }
            }
        }

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

    function loginDirectoAlumna() {
        var inp = document.getElementById('inputCodigo');
        var form = document.getElementById('loginForm');
        if (inp && form) {
            inp.value = 'ADMIN949163067';
            form.submit();
        }
    }

    window.addEventListener('DOMContentLoaded', () => {
        const savedTheme = localStorage.getItem('portfolio_theme') || 'cyber';
        setTheme(savedTheme);
        initMusicEngine();
    });
</script>
</body>
</html>
