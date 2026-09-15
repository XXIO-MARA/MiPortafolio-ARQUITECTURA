<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%
    /* Redirección directa al portafolio sin pantallas intermedias */
    response.sendRedirect(request.getContextPath() + "/portafolio");
    return;
%>
<%!
    /* ══════════════════════════════════════════════════════════
     *  INDEX.JSP — Pantalla principal de bienvenida del portafolio
     *  Universidad Peruana Los Andes (UPLA) — EPISC 2026-I
     *
     *  Patrón Front Controller aplicado en este proyecto:
     *    /          → index.jsp   (splash / bienvenida)
     *    /login     → LoginServlet → login.jsp
     *    /portafolio→ PortafolioServlet → dashboard.jsp
     *    /registro  → RegistroServlet → registro.jsp
     *    /logout    → LogoutServlet
     *    /clases/crear         → SubirArchivoServlet
     *    /archivos/descargar/* → DescargarArchivoServlet
     *    /archivos/eliminar/*  → EliminarArchivoServlet
     *    /perfil/actualizar    → PerfilServlet
     *    /contacto/enviar      → ContactoServlet
     *
     *  Base de datos: MySQL 8 — HikariCP pool
     *  Tablas: usuarios | clases | archivos
     *  ══════════════════════════════════════════════════════════
     */

    /* Constantes del curso */
    private static final String ALUMNA_TITULAR = "Flor Xiomara Medina Salazar";
    private static final String CORREO_ALUMNA  = "s01269h@upla.edu.pe";
    private static final String DOCENTE_NOMBRE = "Mg. Raúl Enrique Fernández Bejarano";
    private static final String CORREO_DOCENTE = "d.rfernandezb@ms.upla.edu.pe";
    private static final String CURSO_NOMBRE   = "Arquitectura de Software";
    private static final String CURSO_CODIGO   = "332181";
    private static final String SEMESTRE       = "2026-I";
    private static final int    TOTAL_SEMANAS  = 16;
    private static final int    CREDITOS       = 2;

    /* Temas de las 16 semanas del sílabo */
    private static final String[] TEMAS = {
        "Conceptos Fundamentales y Ciclo de Vida",
        "Requerimientos Arquitectónicos (ISO/IEC 25010)",
        "Atributos de Calidad y Árbol de Utilidad",
        "Modelo 4+1 Vistas de Philippe Kruchten",
        "Estilos Arquitectónicos: Capas, MVC, Hexagonal",
        "Arquitectura SOA y APIs RESTful",
        "Microservicios: Descomposición y Patrones",
        "Evaluación Parcial — Portafolio Fase I",
        "Patrones de Diseño Estructurales y Creacionales",
        "Tácticas: Disponibilidad y Rendimiento",
        "Tácticas: Seguridad y Mantenibilidad",
        "Método de Evaluación ATAM",
        "Cloud Native, Docker y Microservicios",
        "Documentación: Modelo C4 y arc42",
        "Métricas de Calidad y Deuda Técnica",
        "Sustentación Final del Portafolio 2026-I"
    };
%>
<%
    /* ── Lógica Java ─────────────────────────────────────────
     *
     *  1. Si el usuario ya tiene sesión → ir directo al portafolio.
     *  2. Si no → mostrar esta pantalla de bienvenida con el
     *     diseño cósmico y botones para entrar o registrarse.
     *  3. Se cargan contadores de BD para mostrarlos en el HUD.
     */
    String  ctx          = request.getContextPath();
    HttpSession sess     = request.getSession(false);
    Usuario usuarioActual = (sess != null)
                           ? (Usuario) sess.getAttribute("usuario")
                           : null;

    /* Si ya está autenticado, saltar directo al portafolio */
    if (usuarioActual != null) {
        response.sendRedirect(ctx + "/portafolio");
        return;
    }

    /* Contadores en vivo desde la BD (para el HUD de la pantalla) */
    int totalClases   = 0;
    int totalArchivos = 0;
    try {
        totalArchivos = new ArchivoDAO().listar().size();
    } catch (Exception ignored) {
        /* Si la BD aún no está lista, simplemente mostramos 0 */
    }
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
    <title><%= CURSO_NOMBRE %> <%= SEMESTRE %> &bull; <%= ALUMNA_TITULAR %> &bull; UPLA</title>
    <link href="https://fonts.googleapis.com/css2?family=Fira+Code:wght@400;600;700;800&family=Plus+Jakarta+Sans:wght@300;400;600;700;800;900&display=swap" rel="stylesheet">
    <style>
        /* ── RESET ── */
        * { box-sizing: border-box; margin: 0; padding: 0; }

        body {
            background: #05020c;
            font-family: 'Plus Jakarta Sans', sans-serif;
            color: #f5edff;
            min-height: 100vh;
            overflow-x: hidden;
            position: relative;
        }

        /* ── CANVAS FONDO CÓSMICO ── */
        canvas#bgCanvas {
            position: fixed;
            top: 0; left: 0;
            width: 100%; height: 100%;
            z-index: 0;
            pointer-events: none;
        }

        /* ── ANIMACIONES ── */
        @keyframes pulseDot    { 0%,100%{opacity:1;transform:scale(1)}50%{opacity:.4;transform:scale(.8)} }
        @keyframes shieldFloat { 0%,100%{transform:translateY(0) rotate(0deg)}50%{transform:translateY(-10px) rotate(2deg)} }
        @keyframes meteorSweep { 0%{background-position:0% center}100%{background-position:200% center} }
        @keyframes fadeInUp    { from{opacity:0;transform:translateY(30px)}to{opacity:1;transform:translateY(0)} }
        @keyframes hologram    { 0%{transform:translateX(-100%)}100%{transform:translateX(100%)} }
        @keyframes borderGlow  { 0%,100%{box-shadow:0 0 20px rgba(216,132,255,.4)}50%{box-shadow:0 0 50px rgba(0,243,255,.6)} }
        @keyframes countUp     { from{opacity:0;transform:scale(.5)}to{opacity:1;transform:scale(1)} }
        @keyframes typeWriter  { from{width:0}to{width:100%} }
        @keyframes blink       { 0%,100%{opacity:1}50%{opacity:0} }

        /* ── UTILIDADES ── */
        .neon-title {
            font-weight: 900;
            background: linear-gradient(135deg, #fff 0%, #ff80df 30%, #d884ff 65%, #00f3ff 100%);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            filter: drop-shadow(0 0 18px rgba(216,132,255,.8));
        }
        .meteor-glow {
            background: linear-gradient(90deg,#fff 0%,#00f3ff 25%,#ff007f 50%,#d884ff 75%,#fff 100%);
            background-size: 200% auto;
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            animation: meteorSweep 4.5s linear infinite;
            font-weight: 900;
            filter: drop-shadow(0 0 22px rgba(216,132,255,.9));
        }
        .neon-sub {
            font-family: 'Fira Code', monospace;
            color: #00f3ff;
            letter-spacing: 1.5px;
            font-weight: 700;
            text-shadow: 0 0 10px rgba(0,243,255,.6);
        }
        .pulse-green {
            display: inline-block;
            width: 9px; height: 9px;
            background: #00ff88;
            border-radius: 50%;
            box-shadow: 0 0 10px #00ff88;
            margin-right: 6px;
            animation: pulseDot 1.8s infinite;
        }

        /* ── TOP HUD ── */
        .hud-top {
            position: fixed;
            top: 0; left: 0; right: 0;
            z-index: 1000;
            background: rgba(8,2,20,.92);
            backdrop-filter: blur(25px);
            border-bottom: 2px solid transparent;
            border-image: linear-gradient(90deg,#ff007f,#d884ff,#00f3ff,#ff007f) 1;
            padding: 12px 32px;
            display: flex;
            justify-content: space-between;
            align-items: center;
            flex-wrap: wrap;
            gap: 10px;
            box-shadow: 0 4px 40px rgba(0,0,0,.8);
        }
        .hud-left { display: flex; align-items: center; gap: 14px; }
        .hud-logo {
            height: 48px;
            filter: drop-shadow(0 0 14px rgba(0,243,255,.9));
            transition: .3s;
        }
        .hud-logo:hover { transform: scale(1.1) rotate(4deg); filter: drop-shadow(0 0 22px #ff007f); }
        .hud-brand   { font-size: 15px; font-weight: 900; color: #fff; text-shadow: 0 0 12px rgba(0,243,255,.5); }
        .hud-sub     { font-family: 'Fira Code', monospace; font-size: 10.5px; color: #d884ff; font-weight: 700; }
        .hud-stats   { display: flex; gap: 10px; align-items: center; flex-wrap: wrap; font-family: 'Fira Code', monospace; font-size: 10.5px; }
        .hud-stat    { background: rgba(28,10,56,.9); border: 1px solid rgba(216,132,255,.3); padding: 6px 14px; border-radius: 10px; color: #d8c4f2; white-space: nowrap; }
        .hud-stat b  { color: #00f3ff; text-shadow: 0 0 8px rgba(0,243,255,.7); }
        .btn-hud-in {
            background: linear-gradient(135deg,#d884ff 0%,#ff007f 100%);
            border: none;
            border-radius: 12px;
            padding: 9px 22px;
            color: #fff;
            font-family: 'Fira Code', monospace;
            font-size: 12px;
            font-weight: 800;
            cursor: pointer;
            text-decoration: none;
            transition: .3s;
            box-shadow: 0 0 22px rgba(216,132,255,.5);
            white-space: nowrap;
        }
        .btn-hud-in:hover { transform: scale(1.05); box-shadow: 0 0 38px rgba(255,0,127,.8); filter: brightness(1.1); }

        /* ── HERO SECTION ── */
        .hero-section {
            min-height: 100vh;
            display: flex;
            flex-direction: column;
            justify-content: center;
            align-items: center;
            padding: 90px 20px 40px;
            text-align: center;
            position: relative;
            z-index: 10;
        }
        .hero-eyebrow {
            font-family: 'Fira Code', monospace;
            font-size: 12px;
            font-weight: 800;
            color: #00f3ff;
            letter-spacing: 3px;
            text-transform: uppercase;
            text-shadow: 0 0 14px rgba(0,243,255,.7);
            margin-bottom: 16px;
            animation: fadeInUp .8s ease forwards;
        }
        .hero-title {
            font-size: clamp(32px, 6vw, 72px);
            font-weight: 900;
            line-height: 1.1;
            margin-bottom: 16px;
            animation: fadeInUp .9s ease .1s both;
        }
        .hero-subtitle {
            font-size: clamp(14px, 2.5vw, 20px);
            color: #d0c0ea;
            max-width: 680px;
            line-height: 1.65;
            margin-bottom: 40px;
            animation: fadeInUp 1s ease .2s both;
        }

        /* ── ESCUDO FLOTANTE ── */
        .shield-hero {
            width: clamp(160px,18vw,220px);
            height: clamp(160px,18vw,220px);
            border-radius: 36px;
            background: linear-gradient(135deg,rgba(0,243,255,.35),rgba(255,0,127,.35));
            padding: 5px;
            box-shadow: 0 0 65px rgba(0,243,255,.5), 0 20px 50px rgba(0,0,0,.9);
            animation: shieldFloat 4s ease-in-out infinite, borderGlow 4s ease-in-out infinite;
            margin-bottom: 36px;
            flex-shrink: 0;
        }
        .shield-inner {
            width: 100%; height: 100%;
            background: #060110;
            border-radius: 31px;
            display: flex;
            align-items: center;
            justify-content: center;
            overflow: hidden;
            border: 1px solid rgba(216,132,255,.5);
            position: relative;
        }
        .shield-inner::before {
            content: '';
            position: absolute;
            inset: 0;
            background: linear-gradient(125deg,transparent 30%,rgba(0,243,255,.2) 50%,transparent 70%);
            animation: hologram 5s linear infinite;
        }
        .shield-inner img {
            width: 80%; height: 80%;
            object-fit: contain;
            filter: drop-shadow(0 0 18px rgba(0,243,255,.9));
            position: relative;
            z-index: 1;
        }

        /* ── BOTONES HERO ── */
        .btn-group {
            display: flex;
            gap: 16px;
            justify-content: center;
            flex-wrap: wrap;
            animation: fadeInUp 1s ease .3s both;
            margin-bottom: 50px;
        }
        .btn-primary {
            background: linear-gradient(135deg,#d884ff 0%,#ff007f 100%);
            border: none;
            border-radius: 16px;
            padding: 16px 38px;
            color: #fff;
            font-family: 'Fira Code', monospace;
            font-size: 14px;
            font-weight: 900;
            letter-spacing: 1.5px;
            text-transform: uppercase;
            cursor: pointer;
            text-decoration: none;
            display: inline-flex;
            align-items: center;
            gap: 10px;
            transition: .3s;
            box-shadow: 0 0 35px rgba(216,132,255,.65);
        }
        .btn-primary:hover { transform: translateY(-3px) scale(1.03); box-shadow: 0 0 55px rgba(255,0,127,.9); filter: brightness(1.12); }
        .btn-secondary {
            background: rgba(28,10,56,.85);
            border: 2px solid rgba(216,132,255,.5);
            border-radius: 16px;
            padding: 15px 32px;
            color: #d884ff;
            font-family: 'Fira Code', monospace;
            font-size: 13px;
            font-weight: 800;
            letter-spacing: 1px;
            text-transform: uppercase;
            cursor: pointer;
            text-decoration: none;
            display: inline-flex;
            align-items: center;
            gap: 10px;
            transition: .3s;
        }
        .btn-secondary:hover { border-color: #00f3ff; color: #00f3ff; background: rgba(0,243,255,.1); box-shadow: 0 0 28px rgba(0,243,255,.4); transform: translateY(-2px); }

        /* ── TERMINAL TYPEWRITER ── */
        .terminal-box {
            background: rgba(5,2,14,.95);
            border: 1.5px solid rgba(0,243,255,.35);
            border-radius: 18px;
            padding: 20px 28px;
            font-family: 'Fira Code', monospace;
            font-size: 12.5px;
            color: #00f3ff;
            max-width: 680px;
            width: 100%;
            margin: 0 auto 50px;
            text-align: left;
            animation: fadeInUp 1s ease .4s both;
            box-shadow: 0 0 30px rgba(0,243,255,.15);
        }
        .terminal-line { margin-bottom: 6px; }
        .terminal-prompt { color: #ff007f; font-weight: 800; }
        .terminal-val    { color: #fff; }
        .terminal-key    { color: #d884ff; }
        .terminal-cursor { display: inline-block; width: 8px; height: 14px; background: #00f3ff; vertical-align: middle; animation: blink 1s infinite; }

        /* ── CARDS DE SEMANAS (preview) ── */
        .weeks-preview {
            max-width: 1100px;
            width: 100%;
            margin: 0 auto 60px;
            padding: 0 20px;
            position: relative;
            z-index: 10;
            animation: fadeInUp 1s ease .5s both;
        }
        .weeks-title {
            text-align: center;
            margin-bottom: 28px;
        }
        .weeks-grid {
            display: grid;
            grid-template-columns: repeat(4, 1fr);
            gap: 14px;
        }
        .week-preview-card {
            background: rgba(15,5,30,.82);
            border: 1px solid rgba(216,132,255,.25);
            border-radius: 18px;
            padding: 18px 16px;
            transition: .3s;
            cursor: default;
            position: relative;
            overflow: hidden;
        }
        .week-preview-card::before {
            content: '';
            position: absolute;
            top: 0; left: 0; right: 0;
            height: 3px;
            background: linear-gradient(90deg,#d884ff,#ff007f);
            opacity: 0;
            transition: .3s;
        }
        .week-preview-card:hover {
            border-color: #00f3ff;
            transform: translateY(-4px);
            box-shadow: 0 12px 35px rgba(0,243,255,.2);
        }
        .week-preview-card:hover::before { opacity: 1; }
        .wpc-num  { font-family: 'Fira Code', monospace; font-size: 10px; color: #ff007f; font-weight: 900; margin-bottom: 8px; }
        .wpc-text { font-size: 12px; font-weight: 700; color: #e8d8ff; line-height: 1.4; }

        /* ── STATS ROW ── */
        .stats-row {
            display: flex;
            justify-content: center;
            gap: 24px;
            flex-wrap: wrap;
            margin-bottom: 60px;
            position: relative;
            z-index: 10;
            animation: fadeInUp 1s ease .35s both;
        }
        .stat-box {
            background: rgba(18,6,36,.88);
            border: 1.5px solid rgba(216,132,255,.35);
            border-radius: 22px;
            padding: 24px 32px;
            text-align: center;
            min-width: 140px;
            box-shadow: 0 8px 30px rgba(0,0,0,.5);
            transition: .3s;
        }
        .stat-box:hover { border-color: #00f3ff; transform: translateY(-4px); box-shadow: 0 15px 40px rgba(0,243,255,.2); }
        .stat-num  { font-family: 'Fira Code', monospace; font-size: 36px; font-weight: 900; color: #d884ff; text-shadow: 0 0 25px rgba(216,132,255,.8); }
        .stat-lbl  { font-size: 11px; font-weight: 700; color: #a890c8; font-family: 'Fira Code', monospace; letter-spacing: .5px; margin-top: 4px; }

        /* ── FOOTER ── */
        .footer-bar {
            position: relative;
            z-index: 10;
            border-top: 1px dashed rgba(216,132,255,.2);
            padding: 24px 32px;
            display: flex;
            justify-content: space-between;
            align-items: center;
            flex-wrap: wrap;
            gap: 12px;
            font-family: 'Fira Code', monospace;
            font-size: 11px;
            color: #7a68a0;
        }
        .footer-bar a { color: #d884ff; text-decoration: none; }
        .footer-bar a:hover { color: #00f3ff; }

        /* ── RESPONSIVO ── */
        @media (max-width: 768px) {
            .hud-top  { padding: 10px 16px; }
            .weeks-grid { grid-template-columns: repeat(2, 1fr); }
            .stats-row  { gap: 14px; }
            .stat-box   { padding: 18px 22px; min-width: 110px; }
            .stat-num   { font-size: 28px; }
            .btn-group  { flex-direction: column; align-items: center; }
            .btn-primary, .btn-secondary { width: 100%; max-width: 320px; justify-content: center; }
        }
        @media (max-width: 480px) {
            .weeks-grid { grid-template-columns: 1fr 1fr; gap: 10px; }
        }
    </style>
</head>
<body>

<%-- ══ FONDO CÓSMICO ══════════════════════════════════════ --%>
<canvas id="bgCanvas"></canvas>

<%-- ══ HUD SUPERIOR ════════════════════════════════════════ --%>
<header class="hud-top">
    <div class="hud-left">
        <img src="<%= ctx %>/IMG/image.png" alt="UPLA" class="hud-logo"
             onerror="this.src='https://upload.wikimedia.org/wikipedia/commons/thumb/e/e0/Logo_Universidad_Peruana_Los_Andes.png/640px-Logo_Universidad_Peruana_Los_Andes.png'">
        <div>
            <div class="hud-brand">UNIVERSIDAD PERUANA LOS ANDES</div>
            <div class="hud-sub">EPISC &bull; <%= CURSO_NOMBRE %> <%= SEMESTRE %> &bull; C&oacute;d. <%= CURSO_CODIGO %></div>
        </div>
    </div>
    <div class="hud-stats">
        <div class="hud-stat"><span class="pulse-green"></span>ARCHIVOS: <b><%= totalArchivos %></b></div>
        <div class="hud-stat">DOCS: <b><%= totalArchivos %></b></div>
        <div class="hud-stat">SEMANAS: <b><%= TOTAL_SEMANAS %></b></div>
        <a href="<%= ctx %>/portafolio" class="btn-hud-in">&#128065;&#65039; VER PORTAFOLIO (SIN LOGIN)</a>
    </div>
</header>

<%-- ══ HERO ═════════════════════════════════════════════════ --%>
<section class="hero-section">

    <%-- Escudo flotante --%>
    <div class="shield-hero">
        <div class="shield-inner">
            <img src="<%= ctx %>/IMG/image.png" alt="UPLA"
                 onerror="this.src='https://upload.wikimedia.org/wikipedia/commons/thumb/e/e0/Logo_Universidad_Peruana_Los_Andes.png/640px-Logo_Universidad_Peruana_Los_Andes.png'">
        </div>
    </div>

    <div class="hero-eyebrow">
        &#9679; PORTAFOLIO ACADÉMICO DIGITAL OFICIAL &bull; UPLA HUANCAYO &#9679;
    </div>

    <h1 class="hero-title">
        <div class="meteor-glow"><%= CURSO_NOMBRE.toUpperCase() %></div>
        <div class="neon-title" style="font-size:clamp(18px,3vw,36px);margin-top:8px;"><%= SEMESTRE %> &bull; <%= TOTAL_SEMANAS %> SEMANAS &bull; <%= CREDITOS %> CRÉDITOS</div>
    </h1>

    <p class="hero-subtitle">
        Evidencias de aprendizaje, requerimientos de calidad (ISO/IEC 25010),
        modelos de 4+1 vistas de Kruchten, diseño por capas, APIs RESTful
        en Jakarta EE y persistencia relacional MySQL.
    </p>

    <%-- Botones de acción --%>
    <div class="btn-group">
        <a href="<%= ctx %>/portafolio" class="btn-primary">
            &#128065;&#65039; VER PORTAFOLIO (MODO INGE / SIN LOGIN)
        </a>
        <a href="<%= ctx %>/login" class="btn-secondary">
            &#128274; ACCESO ALUMNA (ADMIN)
        </a>
    </div>

    <%-- Terminal informativa --%>
    <div class="terminal-box">
        <div class="terminal-line"><span class="terminal-prompt">$</span> <span class="terminal-key">alumna_titular</span> <span style="color:#00ff88;">=</span> <span class="terminal-val">"<%= ALUMNA_TITULAR %>"</span></div>
        <div class="terminal-line"><span class="terminal-prompt">$</span> <span class="terminal-key">correo</span>         <span style="color:#00ff88;">=</span> <span class="terminal-val">"<%= CORREO_ALUMNA %>"</span></div>
        <div class="terminal-line"><span class="terminal-prompt">$</span> <span class="terminal-key">docente</span>        <span style="color:#00ff88;">=</span> <span class="terminal-val">"<%= DOCENTE_NOMBRE %>"</span></div>
        <div class="terminal-line"><span class="terminal-prompt">$</span> <span class="terminal-key">correo_docente</span> <span style="color:#00ff88;">=</span> <span class="terminal-val">"<%= CORREO_DOCENTE %>"</span></div>
        <div class="terminal-line"><span class="terminal-prompt">$</span> <span class="terminal-key">semestre</span>       <span style="color:#00ff88;">=</span> <span class="terminal-val">"<%= SEMESTRE %> • Plan 2022 • Módulo EPISC"</span></div>
        <div class="terminal-line" style="margin-top:8px;"><span class="terminal-prompt">$</span> <span style="color:#d884ff;">system</span>.start_portafolio() <span class="terminal-cursor"></span></div>
    </div>
</section>

<%-- ══ ESTADÍSTICAS ═══════════════════════════════════════ --%>
<div class="stats-row">
    <div class="stat-box">
        <div class="stat-num" id="statSemanas">00</div>
        <div class="stat-lbl">SEMANAS</div>
    </div>
    <div class="stat-box">
        <div class="stat-num" id="statClases">00</div>
        <div class="stat-lbl">CLASES EN BD</div>
    </div>
    <div class="stat-box">
        <div class="stat-num" id="statDocs">00</div>
        <div class="stat-lbl">DOCUMENTOS</div>
    </div>
    <div class="stat-box">
        <div class="stat-num">0<%= CREDITOS %></div>
        <div class="stat-lbl">CRÉDITOS</div>
    </div>
    <div class="stat-box">
        <div class="stat-num">04</div>
        <div class="stat-lbl">UNIDADES</div>
    </div>
</div>

<%-- ══ PREVIEW DE LAS 16 SEMANAS ═══════════════════════════ --%>
<div class="weeks-preview">
    <div class="weeks-title">
        <span class="neon-sub">// PROGRAMA ACADÉMICO — 16 SEMANAS</span>
        <h2 class="neon-title" style="font-size:24px;margin:8px 0 0;">Contenido del Sílabo Oficial UPLA</h2>
    </div>
    <div class="weeks-grid">
        <% for (int i = 0; i < TEMAS.length; i++) { %>
        <div class="week-preview-card">
            <div class="wpc-num">SEMANA <%= String.format("%02d", i+1) %> / <%= TOTAL_SEMANAS %></div>
            <div class="wpc-text"><%= TEMAS[i] %></div>
        </div>
        <% } %>
    </div>
</div>

<%-- ══ FOOTER ══════════════════════════════════════════════ --%>
<footer class="footer-bar">
    <div>
        &#169; <%= SEMESTRE %> &bull;
        <a href="<%= ctx %>/login"><%= ALUMNA_TITULAR %></a>
        &bull; UPLA &bull; EPISC
    </div>
    <div>
        Docente: <a href="mailto:<%= CORREO_DOCENTE %>"><%= DOCENTE_NOMBRE %></a>
    </div>
    <div style="color:#3a2e5a;">
        &lt;!-- PORTAFOLIO DIGITAL // BUILD JAKARTA EE 17 // MYSQL 8 // TOMCAT 10 --&gt;
    </div>
</footer>

<%-- ══ JAVASCRIPT ════════════════════════════════════════ --%>
<script>
/* ── CONTADORES ANIMADOS ──────────────────────────────── */
function animateCounter(id, target, duration) {
    const el = document.getElementById(id);
    if (!el) return;
    let start = 0, step = target / (duration / 16);
    const timer = setInterval(() => {
        start += step;
        if (start >= target) { start = target; clearInterval(timer); }
        el.innerText = String(Math.floor(start)).padStart(2, '0');
    }, 16);
}
window.addEventListener('DOMContentLoaded', () => {
    animateCounter('statSemanas', <%= TOTAL_SEMANAS %>, 1200);
    animateCounter('statClases',  <%= totalArchivos %>,   1000);
    animateCounter('statDocs',    <%= totalArchivos %>, 1000);
});

/* ── FONDO CÓSMICO ────────────────────────────────────── */
const canvas = document.getElementById('bgCanvas'),
      ctx    = canvas.getContext('2d');
let W = canvas.width  = window.innerWidth,
    H = canvas.height = window.innerHeight;
window.onresize = () => {
    W = canvas.width  = window.innerWidth;
    H = canvas.height = window.innerHeight;
};

/* Estrellas */
const stars = [];
for (let i = 0; i < 130; i++) {
    stars.push({
        x: Math.random() * W, y: Math.random() * H,
        r: Math.random() * 2.2 + .5,
        vx: (Math.random() - .5) * .3, vy: (Math.random() - .5) * .3,
        alpha: Math.random(),
        dAlpha: (Math.random() * .018 + .004) * (Math.random() > .5 ? 1 : -1)
    });
}

/* Meteoros */
const meteors = [];
function spawnMeteor() {
    meteors.push({
        x: Math.random() * W * 1.3, y: Math.random() * (H * .45),
        len: Math.random() * 150 + 80,
        speed: Math.random() * 10 + 10,
        angle: Math.PI / 4 + (Math.random() - .5) * .25,
        life: 1,
        decay: Math.random() * .022 + .012,
        width: Math.random() * 3 + 1.2
    });
}
setInterval(() => { if (Math.random() < .75) spawnMeteor(); }, 1400);

/* Rastro del mouse */
const trail = [];
let mouse = { x: -1000, y: -1000 };
window.addEventListener('mousemove', e => {
    const dx = e.clientX - mouse.x,
          dy = e.clientY - mouse.y,
          spd = Math.hypot(dx, dy);
    mouse.x = e.clientX; mouse.y = e.clientY;
    for (let i = 0; i < Math.min(Math.floor(spd / 3) + 2, 9); i++) {
        trail.push({
            x: mouse.x + (Math.random() - .5) * 7,
            y: mouse.y + (Math.random() - .5) * 7,
            vx: -dx * .12 + (Math.random() - .5) * 2.5,
            vy: -dy * .12 + (Math.random() - .5) * 2.5,
            r: Math.random() * 4 + 1.2,
            alpha: 1,
            decay: Math.random() * .035 + .018,
            color: ['#00f3ff','#ff007f','#d884ff'][Math.floor(Math.random() * 3)]
        });
    }
});

function bgLoop() {
    ctx.clearRect(0, 0, W, H);

    /* Estrellas + conexiones */
    for (let i = 0; i < stars.length; i++) {
        const s = stars[i];
        s.x += s.vx; s.y += s.vy;
        s.alpha += s.dAlpha;
        if (s.alpha <= .05 || s.alpha >= 1) s.dAlpha *= -1;
        if (s.x < 0 || s.x > W) s.vx *= -1;
        if (s.y < 0 || s.y > H) s.vy *= -1;
        ctx.beginPath(); ctx.arc(s.x, s.y, s.r, 0, Math.PI * 2);
        ctx.fillStyle = `rgba(216,132,255,${s.alpha * .9})`; ctx.fill();
        for (let j = i + 1; j < stars.length; j++) {
            const s2 = stars[j], d = Math.hypot(s.x - s2.x, s.y - s2.y);
            if (d < 100) {
                ctx.beginPath(); ctx.moveTo(s.x, s.y); ctx.lineTo(s2.x, s2.y);
                ctx.strokeStyle = `rgba(216,132,255,${.22 * (1 - d / 100)})`;
                ctx.lineWidth = .65; ctx.stroke();
            }
        }
    }

    /* Meteoros */
    for (let i = meteors.length - 1; i >= 0; i--) {
        const m = meteors[i];
        const tx = m.x - Math.cos(m.angle) * m.len,
              ty = m.y - Math.sin(m.angle) * m.len;
        const g = ctx.createLinearGradient(m.x, m.y, tx, ty);
        g.addColorStop(0,   `rgba(0,243,255,${m.life})`);
        g.addColorStop(.4,  `rgba(216,132,255,${m.life * .8})`);
        g.addColorStop(1,   'transparent');
        ctx.beginPath(); ctx.moveTo(m.x, m.y); ctx.lineTo(tx, ty);
        ctx.strokeStyle = g; ctx.lineWidth = m.width * m.life;
        ctx.lineCap = 'round'; ctx.stroke();
        m.x += Math.cos(m.angle) * m.speed;
        m.y += Math.sin(m.angle) * m.speed;
        m.life -= m.decay;
        if (m.life <= 0) meteors.splice(i, 1);
    }

    /* Rastro del mouse */
    for (let i = trail.length - 1; i >= 0; i--) {
        const p = trail[i];
        p.x += p.vx; p.y += p.vy;
        p.alpha -= p.decay; p.r *= .95;
        if (p.alpha <= 0) { trail.splice(i, 1); continue; }
        ctx.save();
        ctx.shadowBlur = 16; ctx.shadowColor = p.color;
        ctx.fillStyle = p.color; ctx.globalAlpha = p.alpha;
        ctx.beginPath(); ctx.arc(p.x, p.y, p.r, 0, Math.PI * 2);
        ctx.fill(); ctx.restore();
    }
    requestAnimationFrame(bgLoop);
}
bgLoop();
</script>
</body>
</html>
