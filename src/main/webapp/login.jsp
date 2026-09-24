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
            var savedTheme = localStorage.getItem('portfolio_theme') || 'sakura';
            document.documentElement.setAttribute('data-theme', savedTheme);
        })();
    </script>
    <style>
        :root, [data-theme="sakura"] {
            --bg-main: #0c0414;
            --bg-card: rgba(28, 8, 36, 0.88);
            --bg-card-subtle: rgba(44, 12, 54, 0.95);
            --border-color: rgba(255, 119, 170, 0.45);
            --border-accent: #ff66b2;
            --text-primary: #fff0f7;
            --text-secondary: #fbb6ce;
            --accent-cyan: #ff77aa;
            --accent-pink: #ff1493;
            --accent-purple: #ff85c0;
            --card-shadow: 0 0 55px rgba(255, 102, 178, 0.45), 0 20px 60px rgba(0, 0, 0, 0.85);
        }

        [data-theme="ghibli"], [data-theme="dark"] {
            --bg-main: #060b24;
            --bg-card: rgba(10, 24, 64, 0.88);
            --bg-card-subtle: rgba(16, 38, 92, 0.95);
            --border-color: rgba(56, 189, 248, 0.45);
            --border-accent: #fbbf24;
            --text-primary: #f0f9ff;
            --text-secondary: #bae6fd;
            --accent-cyan: #38bdf8;
            --accent-pink: #fbbf24;
            --accent-purple: #818cf8;
            --card-shadow: 0 0 55px rgba(56, 189, 248, 0.45), 0 20px 60px rgba(0, 0, 0, 0.85);
        }

        [data-theme="kimetsu"] {
            --bg-main: #06110c;
            --bg-card: rgba(10, 32, 24, 0.88);
            --bg-card-subtle: rgba(14, 42, 32, 0.95);
            --border-color: rgba(0, 240, 168, 0.45);
            --border-accent: #ff3366;
            --text-primary: #f0fdf4;
            --text-secondary: #86efac;
            --accent-cyan: #00f0a8;
            --accent-pink: #ff3366;
            --accent-purple: #10b981;
            --card-shadow: 0 0 55px rgba(0, 240, 168, 0.45), 0 20px 60px rgba(0, 0, 0, 0.85);
        }

        [data-theme="lofi"], [data-theme="synthwave"] {
            --bg-main: #180c06;
            --bg-card: rgba(42, 20, 12, 0.88);
            --bg-card-subtle: rgba(56, 28, 16, 0.95);
            --border-color: rgba(255, 153, 51, 0.45);
            --border-accent: #ffaa44;
            --text-primary: #fff8f0;
            --text-secondary: #fed7aa;
            --accent-cyan: #ffaa44;
            --accent-pink: #ff5533;
            --accent-purple: #ff8800;
            --card-shadow: 0 0 55px rgba(255, 153, 51, 0.4), 0 20px 60px rgba(0, 0, 0, 0.85);
        }

        [data-theme="cyber"], [data-theme="matrix"] {
            --bg-main: #05020c;
            --bg-card: rgba(18, 6, 36, 0.88);
            --bg-card-subtle: rgba(28, 10, 56, 0.95);
            --border-color: rgba(216, 132, 255, 0.42);
            --border-accent: #00f3ff;
            --text-primary: #f5edff;
            --text-secondary: #d0b8ee;
            --accent-cyan: #00f3ff;
            --accent-pink: #ffe600;
            --accent-purple: #ff007f;
            --card-shadow: 0 0 55px rgba(0, 243, 255, 0.45), 0 20px 60px rgba(0, 0, 0, 0.85);
        }

        [data-theme="zen"], [data-theme="light"] {
            --bg-main: #f8fafc;
            --bg-card: rgba(255, 255, 255, 0.97);
            --bg-card-subtle: #f1f5f9;
            --border-color: #cbd5e1;
            --border-accent: #2563eb;
            --text-primary: #0f172a;
            --text-secondary: #475569;
            --accent-cyan: #0284c7;
            --accent-pink: #7c3aed;
            --accent-purple: #2563eb;
            --card-shadow: 0 10px 40px rgba(0, 0, 0, 0.12);
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
            <div class="theme-dropdown-header">// TEMAS INNOVADORES &bull; ESTILO ANIME</div>
            <button type="button" class="theme-opt-btn" data-theme-val="sakura" onclick="setTheme('sakura')">
                <span class="theme-dot" style="background: linear-gradient(135deg, #ff77aa, #ff1493);"></span>
                <div class="theme-info">
                    <span class="theme-name">🌸 Anime Sakura</span>
                    <span class="theme-desc">Pétalos de cerezo flotantes y noche rosa</span>
                </div>
                <i class="fas fa-check theme-check"></i>
            </button>
            <button type="button" class="theme-opt-btn" data-theme-val="ghibli" onclick="setTheme('ghibli')">
                <span class="theme-dot" style="background: linear-gradient(135deg, #38bdf8, #fbbf24);"></span>
                <div class="theme-info">
                    <span class="theme-name">🌌 Kimi no Na wa</span>
                    <span class="theme-desc">Your Name &bull; Crepúsculo, luciérnagas y cometa</span>
                </div>
                <i class="fas fa-check theme-check"></i>
            </button>
            <button type="button" class="theme-opt-btn" data-theme-val="kimetsu" onclick="setTheme('kimetsu')">
                <span class="theme-dot" style="background: linear-gradient(135deg, #00f0a8, #ff3366);"></span>
                <div class="theme-info">
                    <span class="theme-name">⚔️ Kimetsu no Yaiba</span>
                    <span class="theme-desc">Demon Slayer &bull; Katana esmeralda y brasas</span>
                </div>
                <i class="fas fa-check theme-check"></i>
            </button>
            <button type="button" class="theme-opt-btn" data-theme-val="lofi" onclick="setTheme('lofi')">
                <span class="theme-dot" style="background: linear-gradient(135deg, #ffaa44, #ff5533);"></span>
                <div class="theme-info">
                    <span class="theme-name">☕ Ghibli Cafe</span>
                    <span class="theme-desc">Studio Ghibli &bull; Atardecer cálido y lofi</span>
                </div>
                <i class="fas fa-check theme-check"></i>
            </button>
            <button type="button" class="theme-opt-btn" data-theme-val="cyber" onclick="setTheme('cyber')">
                <span class="theme-dot" style="background: linear-gradient(135deg, #00f3ff, #ff007f);"></span>
                <div class="theme-info">
                    <span class="theme-name">⚡ Cyberpunk 2077</span>
                    <span class="theme-desc">Neo Tokyo &bull; Edgerunners y láseres neón</span>
                </div>
                <i class="fas fa-check theme-check"></i>
            </button>
            <button type="button" class="theme-opt-btn" data-theme-val="zen" onclick="setTheme('zen')">
                <span class="theme-dot" style="background: linear-gradient(135deg, #ffffff, #2563eb); border:1px solid #cbd5e1;"></span>
                <div class="theme-info">
                    <span class="theme-name">✨ Minimal Zen</span>
                    <span class="theme-desc">Blanco cristalino de lujo y constelaciones</span>
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
            <label for="inputCodigo" style="font-size:11px; font-family:'Fira Code',monospace; color:var(--accent-cyan); display:flex; justify-content:space-between; margin-bottom:8px; font-weight:800;">
                <span>🔐 CONTRASEÑA O CÓDIGO:</span>
                <span style="color:var(--text-muted); font-size:10px; font-weight:400;">(Escribe tu clave)</span>
            </label>

            <!-- INPUT GROUP CON BOTÓN VER/NO VER AL COSTADO -->
            <div class="input-group" style="position:relative; display:flex; align-items:center; margin-bottom:18px;">
                <span class="input-prefix">&gt;_</span>
                <input type="password" 
                       name="codigo" 
                       id="inputCodigo"
                       value=""
                       placeholder="Escribe tu código o contraseña aquí..."
                       required 
                       autofocus 
                       autocomplete="current-password"
                       style="width:100%; padding:15px 105px 15px 48px;">

                <!-- BOTÓN VER / NO VER CONTRASEÑA AL COSTADO DENTRO DEL INPUT -->
                <button type="button" 
                        id="loginTogglePassBtn"
                        onclick="togglePasswordVisibility('inputCodigo', 'loginPassEyeIcon', 'loginPassEyeLabel')"
                        style="position:absolute; right:8px; top:50%; transform:translateY(-50%); background:rgba(255,255,255,0.08); border:1px solid var(--border-color); color:var(--accent-cyan); border-radius:10px; padding:7px 11px; font-size:11px; font-family:'Fira Code',monospace; font-weight:800; cursor:pointer; display:flex; align-items:center; gap:5px; transition:all 0.2s ease;"
                        title="Ver u ocultar contraseña">
                    <i class="fas fa-eye" id="loginPassEyeIcon"></i>
                    <span id="loginPassEyeLabel">VER</span>
                </button>
            </div>

            <button type="submit" class="btn-login">&#9889; AUTENTICAR Y ACCEDER</button>
        </form>

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
    /* ── UTILIDADES & VER / OCULTAR CONTRASEÑA ──────────── */
    function togglePasswordVisibility(inputId, iconId, labelId) {
        const input = document.getElementById(inputId);
        const icon = document.getElementById(iconId);
        const label = document.getElementById(labelId);
        if (!input) return;
        if (input.type === 'password') {
            input.type = 'text';
            if (icon) icon.className = 'fas fa-eye-slash';
            if (label) label.innerText = 'OCULTAR';
        } else {
            input.type = 'password';
            if (icon) icon.className = 'fas fa-eye';
            if (label) label.innerText = 'VER';
        }
    }

    /* ── MOTOR DE TEMAS EN LOGIN ────────────────────────── */
    let currentThemeMode = 'sakura';
    let themeParticlePalette = ['#ff77aa', '#ff1493', '#ff85c0'];
    let themeStarColor = 'rgba(255,119,170,';

    function normalizeTheme(t) {
        if (!t) return 'sakura';
        t = t.toLowerCase();
        if (t === 'dark') return 'ghibli';
        if (t === 'light') return 'zen';
        if (t === 'matrix') return 'cyber';
        if (t === 'synthwave') return 'lofi';
        return t;
    }

    function setTheme(theme) {
        theme = normalizeTheme(theme);
        currentThemeMode = theme;
        document.documentElement.setAttribute('data-theme', theme);
        localStorage.setItem('portfolio_theme', theme);

        document.querySelectorAll('.theme-opt-btn').forEach(btn => {
            const val = normalizeTheme(btn.getAttribute('data-theme-val'));
            if (val === theme) {
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
        currentThemeMode = theme;
        if (theme === 'sakura') {
            themeParticlePalette = ['#ff77aa', '#ff1493', '#ff85c0', '#ffd6eb'];
            themeStarColor = 'rgba(255,119,170,';
        } else if (theme === 'ghibli') {
            themeParticlePalette = ['#38bdf8', '#fbbf24', '#818cf8', '#67e8f9'];
            themeStarColor = 'rgba(56,189,248,';
        } else if (theme === 'kimetsu') {
            themeParticlePalette = ['#00f0a8', '#ff3366', '#10b981', '#ffaa00'];
            themeStarColor = 'rgba(0,240,168,';
        } else if (theme === 'cyber') {
            themeParticlePalette = ['#00f3ff', '#ffe600', '#ff007f', '#00ff88'];
            themeStarColor = 'rgba(0,243,255,';
        } else if (theme === 'lofi') {
            themeParticlePalette = ['#ffaa44', '#ff5533', '#fed7aa', '#ffea00'];
            themeStarColor = 'rgba(255,170,68,';
        } else if (theme === 'zen') {
            themeParticlePalette = ['#2563eb', '#0284c7', '#7c3aed', '#60a5fa'];
            themeStarColor = 'rgba(37,99,235,';
        }
    }

    /* ── MOTOR DE AUDIO ANIME MELÓDICO EN LOGIN ───────────── */
    const ANIME_TRACKS = [
        {
            name: '🌸 01. Sakura Waltz',
            chords: [
                [174.61, 261.63, 329.63, 440.00],
                [196.00, 246.94, 293.66, 392.00],
                [164.81, 246.94, 329.63, 392.00],
                [220.00, 261.63, 329.63, 440.00]
            ],
            arps: [
                [523.25, 659.25, 587.33, 523.25],
                [493.88, 587.33, 659.25, 783.99],
                [659.25, 587.33, 493.88, 392.00],
                [523.25, 440.00, 493.88, 523.25]
            ],
            stepTime: 3000
        }
    ];

    let isMusicPlaying = false;
    let audioSynthCtx = null;
    let masterGain = null;
    let synthLoopTimer = null;
    let chordStep = 0;

    function initMusicEngine() {
        const savedTrack = localStorage.getItem('portfolio_music_track');
        // Inicializar contexto
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
        if (isMusicPlaying) {
            pauseMusic();
            localStorage.setItem('portfolio_music_enabled', 'false');
        } else {
            playMusic();
            localStorage.setItem('portfolio_music_enabled', 'true');
        }
    }

    function playMusic() {
        try {
            const AudioCtx = window.AudioContext || window.webkitAudioContext;
            if (!audioSynthCtx) audioSynthCtx = new AudioCtx();
            if (audioSynthCtx.state === 'suspended') audioSynthCtx.resume();
        } catch(e) {}

        isMusicPlaying = true;
        updateMusicUI(true);

        if (!masterGain && audioSynthCtx) {
            masterGain = audioSynthCtx.createGain();
            masterGain.gain.setValueAtTime(0.5, audioSynthCtx.currentTime);
            masterGain.connect(audioSynthCtx.destination);
        }

        playAnimeStep();
    }

    function pauseMusic() {
        isMusicPlaying = false;
        if (synthLoopTimer) { clearTimeout(synthLoopTimer); synthLoopTimer = null; }
        updateMusicUI(false);
    }

    function playAnimeStep() {
        if (!isMusicPlaying || !audioSynthCtx) return;
        const now = audioSynthCtx.currentTime;
        const track = ANIME_TRACKS[0];
        const curChord = track.chords[chordStep % track.chords.length];
        const curArp = track.arps[chordStep % track.arps.length];
        chordStep++;

        curChord.forEach((freq, idx) => {
            try {
                const osc = audioSynthCtx.createOscillator();
                const oscHarm = audioSynthCtx.createOscillator();
                const noteGain = audioSynthCtx.createGain();
                const filter = audioSynthCtx.createBiquadFilter();

                filter.type = 'lowpass';
                filter.frequency.setValueAtTime(1600, now);

                osc.type = 'sine';
                osc.frequency.setValueAtTime(freq, now);
                oscHarm.type = 'triangle';
                oscHarm.frequency.setValueAtTime(freq * 2, now);

                noteGain.gain.setValueAtTime(0.001, now);
                noteGain.gain.linearRampToValueAtTime(0.18 / (idx + 1), now + 0.02 + idx * 0.035);
                noteGain.gain.exponentialRampToValueAtTime(0.0001, now + (track.stepTime / 1000) * 0.95);

                osc.connect(filter);
                oscHarm.connect(filter);
                filter.connect(noteGain);
                noteGain.connect(masterGain);

                osc.start(now + idx * 0.035);
                oscHarm.start(now + idx * 0.035);
                osc.stop(now + (track.stepTime / 1000));
                oscHarm.stop(now + (track.stepTime / 1000));
            } catch(e) {}
        });

        if (curArp) {
            curArp.forEach((mFreq, mIdx) => {
                const noteTime = now + 0.25 + mIdx * 0.45;
                try {
                    const mOsc = audioSynthCtx.createOscillator();
                    const mGain = audioSynthCtx.createGain();
                    mOsc.type = 'sine';
                    mOsc.frequency.setValueAtTime(mFreq, noteTime);

                    mGain.gain.setValueAtTime(0.0001, noteTime);
                    mGain.gain.linearRampToValueAtTime(0.14, noteTime + 0.015);
                    mGain.gain.exponentialRampToValueAtTime(0.0001, noteTime + 1.4);

                    mOsc.connect(mGain);
                    mGain.connect(masterGain);
                    mOsc.start(noteTime);
                    mOsc.stop(noteTime + 1.45);
                } catch(e) {}
            });
        }

        synthLoopTimer = setTimeout(playAnimeStep, track.stepTime);
    }

    window.addEventListener('click', () => {
        const shouldPlay = localStorage.getItem('portfolio_music_enabled');
        if (shouldPlay === 'true' && !isMusicPlaying) {
            playMusic();
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

    window.addEventListener('DOMContentLoaded', () => {
        const savedTheme = localStorage.getItem('portfolio_theme') || 'sakura';
        setTheme(savedTheme);
        initMusicEngine();
    });
</script>
</body>
</html>
