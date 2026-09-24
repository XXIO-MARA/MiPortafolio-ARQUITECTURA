<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="com.miportafolio.model.Usuario" %>
<%@ page import="com.miportafolio.model.Archivo" %>
<%@ page import="com.miportafolio.dao.ArchivoDAO" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.ArrayList" %>
<%
    /* ── Datos inyectados por ArchivoServlet ──────────── */
    Usuario  usuario      = (Usuario)  request.getAttribute("usuario");
    boolean  esAdmin      = Boolean.TRUE.equals(request.getAttribute("esAdmin"));
    String   nombreAlumna = (String)   request.getAttribute("nombreAlumna");
    boolean  justLoggedIn = Boolean.TRUE.equals(request.getAttribute("justLoggedIn"));
    String   activeTab    = (String)   request.getAttribute("activeTab");
    String   msg          = (String)   request.getAttribute("msg");

    @SuppressWarnings("unchecked")
    List<Archivo> archivos    = (List<Archivo>) request.getAttribute("archivos");
    String[]      temasSemanas = (String[])      request.getAttribute("temasSemanas");

    int totalArchivos = archivos != null ? archivos.size() : 0;
    if (archivos == null) archivos = new ArrayList<>();

    if (activeTab == null) activeTab = "presentacion";
    String ctx = request.getContextPath();

    int initialSemana = 1;
    String semParam = request.getParameter("semana");
    if (semParam != null) {
        try {
            int parsedSem = Integer.parseInt(semParam.trim());
            if (parsedSem >= 1 && parsedSem <= 16) initialSemana = parsedSem;
        } catch (Exception ignored) {}
    }
%>
<%!
    /* Método utilitario: semana 1-16 → tema del silabo */
    private static String temaDeSemana(String[] temas, int s) {
        if (temas != null && s >= 1 && s <= temas.length) return temas[s - 1];
        return "Semana " + s;
    }
    private static String pad(int n) { return n < 10 ? "0" + n : String.valueOf(n); }
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
    <title>Portafolio &bull; Arquitectura de Software | <%= nombreAlumna %></title>
    <link href="https://fonts.googleapis.com/css2?family=Fira+Code:wght@400;600;700;800&family=Plus+Jakarta+Sans:wght@300;400;600;700;800;900&display=swap" rel="stylesheet">
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
            --bg-surface: rgba(28, 8, 36, 0.88);
            --bg-surface-solid: #1b0724;
            --bg-card: rgba(28, 8, 36, 0.86);
            --bg-card-subtle: rgba(44, 12, 54, 0.92);
            --border-color: rgba(255, 119, 170, 0.45);
            --border-accent: #ff66b2;
            --text-primary: #fff0f7;
            --text-secondary: #fbb6ce;
            --text-muted: #c07a9f;
            --accent-cyan: #ff77aa;
            --accent-pink: #ff1493;
            --accent-purple: #ff85c0;
            --accent-gradient: linear-gradient(135deg, #ff77aa 0%, #ff1493 100%);
            --hud-bg: rgba(20, 6, 26, 0.96);
            --glow-shadow: 0 0 28px rgba(255, 102, 178, 0.45);
            --card-shadow: 0 15px 45px rgba(0, 0, 0, 0.75);
        }

        [data-theme="ghibli"], [data-theme="dark"] {
            --bg-main: #060b24;
            --bg-surface: rgba(8, 18, 52, 0.9);
            --bg-surface-solid: #081438;
            --bg-card: rgba(10, 24, 64, 0.88);
            --bg-card-subtle: rgba(16, 38, 92, 0.94);
            --border-color: rgba(56, 189, 248, 0.45);
            --border-accent: #fbbf24;
            --text-primary: #f0f9ff;
            --text-secondary: #bae6fd;
            --text-muted: #7dd3fc;
            --accent-cyan: #38bdf8;
            --accent-pink: #fbbf24;
            --accent-purple: #818cf8;
            --accent-gradient: linear-gradient(135deg, #38bdf8 0%, #818cf8 50%, #fbbf24 100%);
            --hud-bg: rgba(4, 12, 36, 0.97);
            --glow-shadow: 0 0 30px rgba(56, 189, 248, 0.45);
            --card-shadow: 0 15px 45px rgba(0, 0, 0, 0.75);
        }

        [data-theme="kimetsu"] {
            --bg-main: #06110c;
            --bg-surface: rgba(8, 28, 20, 0.9);
            --bg-surface-solid: #081d14;
            --bg-card: rgba(10, 32, 24, 0.88);
            --bg-card-subtle: rgba(14, 42, 32, 0.94);
            --border-color: rgba(0, 240, 168, 0.45);
            --border-accent: #ff3366;
            --text-primary: #f0fdf4;
            --text-secondary: #86efac;
            --text-muted: #4ade80;
            --accent-cyan: #00f0a8;
            --accent-pink: #ff3366;
            --accent-purple: #10b981;
            --accent-gradient: linear-gradient(135deg, #00f0a8 0%, #ff3366 100%);
            --hud-bg: rgba(6, 20, 14, 0.97);
            --glow-shadow: 0 0 30px rgba(0, 240, 168, 0.45);
            --card-shadow: 0 15px 45px rgba(0, 0, 0, 0.75);
        }

        [data-theme="lofi"], [data-theme="synthwave"] {
            --bg-main: #180c06;
            --bg-surface: rgba(38, 18, 10, 0.9);
            --bg-surface-solid: #26130b;
            --bg-card: rgba(42, 20, 12, 0.88);
            --bg-card-subtle: rgba(56, 28, 16, 0.92);
            --border-color: rgba(255, 153, 51, 0.45);
            --border-accent: #ffaa44;
            --text-primary: #fff8f0;
            --text-secondary: #fed7aa;
            --text-muted: #ea580c;
            --accent-cyan: #ffaa44;
            --accent-pink: #ff5533;
            --accent-purple: #ff8800;
            --accent-gradient: linear-gradient(135deg, #ff8800 0%, #ff5533 100%);
            --hud-bg: rgba(24, 12, 6, 0.96);
            --glow-shadow: 0 0 25px rgba(255, 153, 51, 0.4);
            --card-shadow: 0 15px 45px rgba(0, 0, 0, 0.8);
        }

        [data-theme="cyber"], [data-theme="matrix"] {
            --bg-main: #05020c;
            --bg-surface: rgba(18, 6, 36, 0.88);
            --bg-surface-solid: #120624;
            --bg-card: rgba(18, 6, 36, 0.86);
            --bg-card-subtle: rgba(28, 10, 56, 0.9);
            --border-color: rgba(216, 132, 255, 0.42);
            --border-accent: #00f3ff;
            --text-primary: #f5edff;
            --text-secondary: #cba6f7;
            --text-muted: #957eb5;
            --accent-cyan: #00f3ff;
            --accent-pink: #ffe600;
            --accent-purple: #ff007f;
            --accent-gradient: linear-gradient(135deg, #00f3ff 0%, #ffe600 50%, #ff007f 100%);
            --hud-bg: rgba(12, 4, 26, 0.95);
            --glow-shadow: 0 0 28px rgba(0, 243, 255, 0.45);
            --card-shadow: 0 15px 45px rgba(0, 0, 0, 0.7);
        }

        [data-theme="zen"], [data-theme="light"] {
            --bg-main: #f8fafc;
            --bg-surface: rgba(255, 255, 255, 0.96);
            --bg-surface-solid: #ffffff;
            --bg-card: #ffffff;
            --bg-card-subtle: #f1f5f9;
            --border-color: rgba(203, 213, 225, 0.9);
            --border-accent: #2563eb;
            --text-primary: #0f172a;
            --text-secondary: #334155;
            --text-muted: #64748b;
            --accent-cyan: #0284c7;
            --accent-pink: #7c3aed;
            --accent-purple: #2563eb;
            --accent-gradient: linear-gradient(135deg, #2563eb 0%, #7c3aed 100%);
            --hud-bg: rgba(255, 255, 255, 0.98);
            --glow-shadow: 0 4px 20px rgba(0, 0, 0, 0.08);
            --card-shadow: 0 10px 25px rgba(0, 0, 0, 0.07);
        }

        /* Reglas adaptativas de tema Zen / Claro */
        [data-theme="zen"] body, [data-theme="light"] body { background: #f8fafc !important; color: #0f172a !important; }
        [data-theme="zen"] .hud-brand, [data-theme="light"] .hud-brand { color: #0f172a !important; text-shadow: none !important; }
        [data-theme="zen"] .hud-facultad, [data-theme="light"] .hud-facultad { color: #475569 !important; }
        [data-theme="zen"] .hud-stat, [data-theme="light"] .hud-stat { background: #ffffff !important; border-color: #cbd5e1 !important; color: #334155 !important; }
        [data-theme="zen"] .student-name, [data-theme="light"] .student-name { color: #0f172a !important; text-shadow: none !important; }
        [data-theme="zen"] .meta-val, [data-theme="light"] .meta-val { color: #0f172a !important; }
        [data-theme="zen"] .unit-title, [data-theme="light"] .unit-title { color: #0f172a !important; }
        [data-theme="zen"] .doc-title, [data-theme="light"] .doc-title { color: #0f172a !important; }
        [data-theme="zen"] .doc-desc, [data-theme="light"] .doc-desc { color: #475569 !important; }
        [data-theme="zen"] .week-card-title, [data-theme="light"] .week-card-title { color: #0f172a !important; }
        [data-theme="zen"] .console-title, [data-theme="light"] .console-title { color: #0f172a !important; }
        [data-theme="zen"] .modal-dialog, [data-theme="light"] .modal-dialog { background: #ffffff !important; border-color: #2563eb !important; box-shadow: 0 10px 40px rgba(0,0,0,0.15) !important; color: #0f172a !important; }
        [data-theme="zen"] .cyber-input, [data-theme="zen"] .cyber-textarea, [data-theme="zen"] .cyber-select,
        [data-theme="light"] .cyber-input, [data-theme="light"] .cyber-textarea, [data-theme="light"] .cyber-select { background: #ffffff !important; color: #0f172a !important; border-color: #cbd5e1 !important; }
        [data-theme="zen"] .radio-btn-label, [data-theme="light"] .radio-btn-label { background: #f8fafc !important; border-color: #cbd5e1 !important; color: #0f172a !important; }
        [data-theme="zen"] .cyber-dropzone, [data-theme="light"] .cyber-dropzone { background: #f8fafc !important; border-color: #94a3b8 !important; }
        [data-theme="zen"] .dropzone-text, [data-theme="light"] .dropzone-text { color: #0f172a !important; }
        [data-theme="zen"] .tab-inactive, [data-theme="light"] .tab-inactive { background: #ffffff !important; color: #334155 !important; border-color: #cbd5e1 !important; }
        [data-theme="zen"] .empty-slot, [data-theme="light"] .empty-slot { border-color: #cbd5e1 !important; color: #64748b !important; }
        [data-theme="zen"] .michi-head, [data-theme="light"] .michi-head { background: #f8fafc !important; border-color: #cbd5e1 !important; }
        [data-theme="zen"] #michiWindow, [data-theme="light"] #michiWindow { background: #ffffff !important; border-color: #2563eb !important; }
        [data-theme="zen"] .msg-bot, [data-theme="light"] .msg-bot { background: #f1f5f9 !important; color: #0f172a !important; border-color: #cbd5e1 !important; }
        [data-theme="zen"] .michi-input-box, [data-theme="light"] .michi-input-box { background: #f8fafc !important; border-color: #cbd5e1 !important; }
        [data-theme="zen"] .michi-input, [data-theme="light"] .michi-input { background: #ffffff !important; color: #0f172a !important; border-color: #cbd5e1 !important; }
        [data-theme="zen"] .upla-3d-inner, [data-theme="light"] .upla-3d-inner { background: #ffffff !important; }

        * { box-sizing: border-box; margin: 0; padding: 0; }
        body { background: var(--bg-main); color: var(--text-primary); font-family: 'Plus Jakarta Sans', sans-serif; min-height: 100vh; overflow-x: hidden; transition: background .3s ease, color .3s ease; }
        canvas#bgCanvas { position: fixed; top: 0; left: 0; width: 100%; height: 100%; z-index: 0; pointer-events: none; }

        /* ── UTILIDADES ── */
        .neon-title { font-weight: 900; background: linear-gradient(135deg, #fff 0%, #ff80df 30%, #d884ff 65%, #00f3ff 100%); -webkit-background-clip: text; -webkit-text-fill-color: transparent; filter: drop-shadow(0 0 15px rgba(216,132,255,.75)); }
        .neon-sub   { font-family: 'Fira Code', monospace; color: #00f3ff; letter-spacing: 1.5px; font-weight: 700; text-shadow: 0 0 10px rgba(0,243,255,.6); }
        .meteor-glow { background: linear-gradient(90deg,#fff 0%,#00f3ff 25%,#ff007f 50%,#d884ff 75%,#fff 100%); background-size: 200% auto; -webkit-background-clip: text; -webkit-text-fill-color: transparent; animation: meteorSweep 4.5s linear infinite; font-weight: 900; filter: drop-shadow(0 0 20px rgba(216,132,255,.8)); }
        @keyframes meteorSweep { 0% { background-position: 0% center; } 100% { background-position: 200% center; } }
        @keyframes pulseDot    { 0%,100% { opacity:1; transform:scale(1); }  50% { opacity:.4; transform:scale(.8); } }
        @keyframes shieldFloat { 0%,100% { transform:translateY(0) rotate(0deg); } 50% { transform:translateY(-8px) rotate(1.5deg); } }
        @keyframes hologramScan{ 0% { transform:translateX(-100%); } 100% { transform:translateX(100%); } }
        @keyframes fadeInWeek  { from { opacity:0; transform:translateY(15px); } to { opacity:1; transform:translateY(0); } }
        @keyframes bubbleBounce{ from { transform:translateY(0); } to { transform:translateY(-5px); } }

        /* ── LOADER ── */
        #cyberLoader { position: fixed; inset: 0; background: #05020c; z-index: 999999; display: flex; flex-direction: column; align-items: center; justify-content: center; padding: 20px; transition: opacity .7s ease; }
        .loader-card { background: rgba(20,7,40,.94); border: 1.5px solid rgba(216,132,255,.5); border-radius: 26px; padding: 38px 42px; text-align: center; box-shadow: 0 0 60px rgba(216,132,255,.4); backdrop-filter: blur(25px); max-width: 520px; width: 100%; }
        .loader-pct  { font-family: 'Fira Code', monospace; font-size: 52px; font-weight: 900; color: #d884ff; text-shadow: 0 0 35px rgba(216,132,255,.9); margin: 14px 0; }
        .loader-bar-bg   { width: 100%; height: 9px; background: rgba(255,255,255,.08); border-radius: 20px; overflow: hidden; border: 1px solid rgba(216,132,255,.3); }
        .loader-bar-fill { height: 100%; width: 0%; background: linear-gradient(90deg,#00f3ff,#d884ff,#ff007f); border-radius: 20px; box-shadow: 0 0 20px #ff007f; transition: width .05s linear; }
        .loader-status  { font-family: 'Fira Code', monospace; font-size: 11.5px; color: #00f3ff; letter-spacing: 1px; margin-top: 14px; font-weight: 700; }
        .loader-welcome { display: none; font-size: 19px; font-weight: 900; color: #fff; text-shadow: 0 0 22px #ff007f; margin-top: 16px; }

        /* ── HUD TOP ── */
        .hud-top { background: rgba(12,4,26,.95); backdrop-filter: blur(25px); border-bottom: 2px solid transparent; border-image: linear-gradient(90deg,#ff007f,#d884ff,#00f3ff,#ff007f) 1; padding: 16px 36px; display: flex; justify-content: space-between; align-items: center; position: sticky; top: 0; z-index: 1000; box-shadow: 0 8px 45px rgba(0,0,0,.9); flex-wrap: wrap; gap: 12px; }
        .hud-left    { display: flex; align-items: center; gap: 16px; }
        .hud-logo    { height: 56px; filter: drop-shadow(0 0 18px rgba(0,243,255,.9)); transition: .3s; cursor: pointer; }
        .hud-logo:hover { transform: scale(1.08) rotate(3deg); filter: drop-shadow(0 0 25px #ff007f); }
        .hud-brand   { font-size: 17.5px; font-weight: 900; color: #fff; letter-spacing: .8px; text-shadow: 0 0 15px rgba(0,243,255,.5); }
        .hud-facultad{ font-family: 'Fira Code', monospace; font-size: 11px; color: #d884ff; font-weight: 700; }
        .telemetry-hud { display: flex; gap: 12px; align-items: center; font-family: 'Fira Code', monospace; font-size: 11px; flex-wrap: wrap; }
        .hud-stat    { background: rgba(28,10,56,.92); border: 1px solid rgba(216,132,255,.35); padding: 8px 15px; border-radius: 12px; color: #d8c4f2; white-space: nowrap; }
        .hud-stat b  { color: #00f3ff; text-shadow: 0 0 8px rgba(0,243,255,.7); }
        .pulse-green { display: inline-block; width: 8px; height: 8px; background: #00ff88; border-radius: 50%; box-shadow: 0 0 10px #00ff88; margin-right: 6px; animation: pulseDot 1.8s infinite; }
        .user-badge-admin { background: linear-gradient(135deg,rgba(255,0,127,.22),rgba(216,132,255,.22)); border: 1.5px solid #ff007f; color: #ff80df; padding: 8px 18px; border-radius: 22px; font-weight: 900; box-shadow: 0 0 25px rgba(255,0,127,.5); white-space: nowrap; font-size: 12px; }
        .user-badge-est   { background: rgba(0,243,255,.18); border: 1.5px solid #00f3ff; color: #00f3ff; padding: 8px 18px; border-radius: 22px; font-weight: 900; white-space: nowrap; font-size: 12px; }
        .btn-exit { background: rgba(255,0,80,.18); border: 1px solid #ff0055; color: #ff6688; padding: 8px 16px; border-radius: 10px; font-weight: 800; text-decoration: none; transition: .3s; white-space: nowrap; font-family: 'Fira Code', monospace; }
        .btn-exit:hover { background: #ff0055; color: #fff; box-shadow: 0 0 22px #ff0055; }

        /* ── ALERTAS ── */
        .alert-top { padding: 11px 20px; font-family: 'Fira Code', monospace; font-size: 12px; text-align: center; position: relative; z-index: 900; }
        .alert-ok   { background: rgba(0,243,255,.14); border-bottom: 1px solid #00f3ff; color: #00f3ff; box-shadow: 0 0 18px rgba(0,243,255,.25); }
        .alert-del  { background: rgba(255,0,80,.15);  border-bottom: 1px solid #ff0055; color: #ff6688; }
        .alert-msg  { background: rgba(0,255,136,.12); border-bottom: 1px solid #00ff88; color: #00ff88; }

        /* ── TABS ── */
        .tabs-bar   { display: flex; justify-content: center; gap: 16px; margin: 26px 0 20px; position: relative; z-index: 10; flex-wrap: wrap; padding: 0 15px; }
        .tab-link   { padding: 14px 28px; border-radius: 16px; text-decoration: none; font-weight: 800; font-size: 12.5px; letter-spacing: 1px; text-transform: uppercase; transition: .3s; font-family: 'Fira Code', monospace; display: inline-flex; align-items: center; gap: 8px; }
        .tab-active { background: linear-gradient(135deg,#d884ff 0%,#ff007f 100%); color: #fff; box-shadow: 0 0 32px rgba(216,132,255,.75); transform: scale(1.02); }
        .tab-inactive { background: rgba(25,8,48,.75); border: 1px solid rgba(216,132,255,.25); color: #c4a7f2; }
        .tab-inactive:hover { background: rgba(38,13,74,.9); color: #fff; border-color: #d884ff; }

        /* ── LAYOUT ── */
        .main-content { max-width: 1320px; margin: 0 auto; padding: 15px 20px 110px; position: relative; z-index: 10; }

        /* ── HERO ── */
        .hero-showcase { background: linear-gradient(135deg,rgba(20,7,42,.92) 0%,rgba(10,3,24,.95) 100%); border: 1.8px solid rgba(0,243,255,.45); border-radius: 28px; padding: 38px 42px; margin-bottom: 32px; box-shadow: 0 0 50px rgba(0,243,255,.2),0 20px 60px rgba(0,0,0,.8); display: grid; grid-template-columns: 1fr auto; gap: 36px; align-items: center; position: relative; overflow: hidden; }
        .hero-showcase::before { content: ''; position: absolute; top: -40%; right: -10%; width: 320px; height: 320px; background: radial-gradient(circle,rgba(255,0,127,.22),transparent 70%); filter: blur(40px); pointer-events: none; }
        .hero-left-content { position: relative; z-index: 2; }
        .hero-tags-row  { display: flex; flex-wrap: wrap; gap: 10px; margin-top: 20px; }
        .hero-tag-item  { background: rgba(255,255,255,.04); border: 1px solid rgba(216,132,255,.28); border-radius: 10px; padding: 6px 14px; font-family: 'Fira Code', monospace; font-size: 11.5px; color: #cbd5e1; display: flex; align-items: center; gap: 6px; }
        .hero-tag-item b{ color: #00f3ff; }
        .upla-3d-box    { position: relative; z-index: 2; display: flex; flex-direction: column; align-items: center; }
        .upla-3d-shield { width: 140px; height: 140px; border-radius: 28px; background: linear-gradient(135deg,rgba(0,243,255,.3),rgba(255,0,127,.3)); padding: 4px; box-shadow: 0 0 45px rgba(0,243,255,.45),0 15px 35px rgba(0,0,0,.8); animation: shieldFloat 4s ease-in-out infinite; }
        .upla-3d-inner  { width: 100%; height: 100%; background: #090418; border-radius: 24px; display: flex; align-items: center; justify-content: center; overflow: hidden; border: 1px solid rgba(216,132,255,.4); }
        .upla-3d-inner img { width: 80%; height: 80%; object-fit: contain; filter: drop-shadow(0 0 12px rgba(0,243,255,.85)); }
        .upla-3d-caption{ margin-top: 10px; font-family: 'Fira Code', monospace; font-size: 11px; font-weight: 800; color: #38bdf8; letter-spacing: 1px; text-shadow: 0 0 8px #00f3ff; }

        /* ── CARDS ── */
        .dossier-grid   { display: grid; grid-template-columns: 1fr 1fr; gap: 26px; margin-bottom: 32px; }
        .cyber-card     { background: rgba(18,6,36,.86); border: 1.5px solid rgba(216,132,255,.38); border-radius: 26px; padding: 32px; backdrop-filter: blur(25px); box-shadow: 0 15px 45px rgba(0,0,0,.65); position: relative; overflow: hidden; }
        .cyber-card::before { content: ''; position: absolute; top: 0; left: 0; width: 100%; height: 4px; background: linear-gradient(90deg,#00f3ff,#d884ff,#ff007f); }
        .docente-card-pro { background: linear-gradient(135deg,rgba(24,8,48,.92) 0%,rgba(12,4,30,.95) 100%); border-color: rgba(168,85,247,.55); }
        .docente-header   { display: flex; gap: 20px; align-items: center; margin-bottom: 22px; }
        .docente-avatar-frame { width: 95px; height: 95px; border-radius: 24px; border: 2.5px solid #a855f7; background: radial-gradient(circle,#2e0854 0%,#100220 100%); display: flex; align-items: center; justify-content: center; font-size: 42px; box-shadow: 0 0 35px rgba(168,85,247,.6); position: relative; flex-shrink: 0; }
        .docente-spec-grid{ display: grid; grid-template-columns: repeat(2,1fr); gap: 14px; margin: 20px 0; }
        .docente-spec-box { background: rgba(255,255,255,.035); border: 1px solid rgba(168,85,247,.3); border-radius: 14px; padding: 13px 15px; }
        .btn-docente-mail { display: inline-flex; align-items: center; gap: 8px; background: linear-gradient(135deg,rgba(168,85,247,.25),rgba(0,243,255,.25)); border: 1.5px solid #a855f7; color: #fff; padding: 10px 20px; border-radius: 12px; font-family: 'Fira Code', monospace; font-size: 11.5px; font-weight: 800; text-decoration: none; transition: .3s; margin-top: 6px; }
        .btn-docente-mail:hover { background: #a855f7; box-shadow: 0 0 25px #a855f7; transform: translateY(-1px); }

        /* ── ALUMNA ── */
        .student-header   { display: flex; gap: 22px; align-items: center; margin-bottom: 22px; }
        .avatar-frame     { width: 95px; height: 95px; border-radius: 24px; border: 2.5px solid #ff007f; background: radial-gradient(circle,#381266 0%,#150529 100%); display: flex; align-items: center; justify-content: center; box-shadow: 0 0 35px rgba(255,0,127,.6); position: relative; flex-shrink: 0; overflow: hidden; }
        .chip-badge       { position: absolute; bottom: -6px; right: -6px; background: #ff007f; color: #fff; font-size: 9.5px; font-family: 'Fira Code', monospace; padding: 3px 9px; border-radius: 12px; font-weight: 900; box-shadow: 0 0 10px #ff007f; }
        .student-name     { font-size: 24px; font-weight: 900; color: #fff; text-shadow: 0 0 18px rgba(216,132,255,.6); margin-bottom: 4px; }
        .student-title    { font-family: 'Fira Code', monospace; font-size: 12px; color: #00f3ff; letter-spacing: 1px; font-weight: 700; }
        .meta-list        { display: grid; grid-template-columns: repeat(2,1fr); gap: 14px; margin: 20px 0; }
        .meta-item        { background: rgba(255,255,255,.035); border: 1px solid rgba(216,132,255,.22); border-radius: 14px; padding: 13px 15px; }
        .meta-lbl         { font-size: 10.5px; text-transform: uppercase; color: #c7a6f7; font-family: 'Fira Code', monospace; margin-bottom: 4px; font-weight: 700; }
        .meta-val         { font-size: 13.5px; font-weight: 800; color: #fff; }
        .edit-profile-btn { background: rgba(216,132,255,.18); border: 1px solid #d884ff; color: #fff; padding: 10px 22px; border-radius: 12px; font-size: 12px; font-weight: 800; cursor: pointer; font-family: 'Fira Code', monospace; transition: .3s; margin-top: 10px; }
        .edit-profile-btn:hover { background: #d884ff; color: #070210; box-shadow: 0 0 25px #d884ff; }
        .readonly-tag     { font-family: 'Fira Code', monospace; font-size: 11px; color: #9d85c8; background: rgba(255,255,255,.03); padding: 8px 15px; border-radius: 10px; border: 1px dashed rgba(255,255,255,.18); display: inline-block; margin-top: 10px; }

        /* ── UNIDADES ── */
        .units-grid  { display: grid; grid-template-columns: repeat(4,1fr); gap: 18px; margin-top: 18px; }
        .unit-card   { background: rgba(18,6,36,.75); border: 1px solid rgba(216,132,255,.28); border-radius: 20px; padding: 22px; transition: .3s; }
        .unit-card:hover { border-color: #00f3ff; transform: translateY(-3px); box-shadow: 0 10px 30px rgba(0,243,255,.25); }
        .unit-badge  { font-family: 'Fira Code', monospace; font-size: 10px; font-weight: 900; color: #ff007f; background: rgba(255,0,127,.18); padding: 4px 10px; border-radius: 8px; display: inline-block; margin-bottom: 10px; }
        .unit-title  { font-size: 13px; font-weight: 800; color: #fff; margin-bottom: 14px; line-height: 1.45; min-height: 52px; }
        .reactor-bar { height: 7px; background: rgba(255,255,255,.08); border-radius: 10px; overflow: hidden; margin-bottom: 9px; }
        .reactor-fill{ height: 100%; border-radius: 10px; }

        /* ── UPLOAD CONSOLE ── */
        .upload-console  { background: rgba(20,7,40,.88); border: 1.5px solid rgba(216,132,255,.4); border-radius: 26px; padding: 30px; margin-bottom: 32px; backdrop-filter: blur(25px); }
        .console-header  { display: flex; justify-content: space-between; align-items: center; margin-bottom: 20px; border-bottom: 1px solid rgba(216,132,255,.25); padding-bottom: 12px; }
        .console-title   { font-size: 16.5px; font-weight: 900; color: #fff; }
        .form-grid       { display: grid; grid-template-columns: 1fr 1fr; gap: 18px; }
        .cyber-input, .cyber-textarea, .cyber-select { width: 100%; background: rgba(28,10,56,.9); border: 1px solid rgba(216,132,255,.32); border-radius: 12px; padding: 13px 15px; color: #fff; font-size: 13px; outline: none; font-family: 'Plus Jakarta Sans', sans-serif; transition: .3s; }
        .cyber-input:focus, .cyber-textarea:focus { border-color: #ff007f; box-shadow: 0 0 18px rgba(255,0,127,.45); }
        .cyber-textarea  { resize: vertical; }
        .type-selector   { display: flex; gap: 14px; margin: 9px 0; }
        .radio-btn-label { flex: 1; background: rgba(255,255,255,.035); border: 1px solid rgba(216,132,255,.28); border-radius: 14px; padding: 12px; cursor: pointer; display: flex; align-items: center; gap: 8px; font-size: 12px; font-weight: 800; transition: .3s; }
        .radio-btn-label:hover { border-color: #d884ff; background: rgba(216,132,255,.12); }
        .radio-btn-label input[type=radio] { accent-color: #ff007f; width: 17px; height: 17px; }
        .cyber-dropzone  { border: 2px dashed rgba(216,132,255,.5); background: rgba(28,10,56,.65); border-radius: 18px; padding: 24px; text-align: center; cursor: pointer; transition: .3s; margin-top: 15px; }
        .cyber-dropzone:hover { border-color: #ff007f; background: rgba(255,0,127,.1); box-shadow: 0 0 30px rgba(255,0,127,.35); transform: translateY(-2px); }
        .dropzone-icon   { font-size: 32px; margin-bottom: 6px; }
        .dropzone-text   { font-size: 13px; font-weight: 800; color: #fff; margin-bottom: 3px; }
        .dropzone-sub    { font-size: 11.5px; font-family: 'Fira Code', monospace; color: #00f3ff; }
        .submit-btn      { background: linear-gradient(135deg,#d884ff 0%,#ff007f 100%); border: none; border-radius: 14px; padding: 15px 25px; color: #fff; font-weight: 900; font-size: 13px; letter-spacing: 1px; cursor: pointer; transition: .3s; box-shadow: 0 0 24px rgba(216,132,255,.45); text-transform: uppercase; font-family: 'Fira Code', monospace; margin-top: 18px; width: 100%; }
        .submit-btn:hover{ transform: scale(1.01); box-shadow: 0 0 35px rgba(255,0,127,.75); filter: brightness(1.1); }

        /* ── CARRUSEL ── */
        .carousel-nav    { display: flex; justify-content: space-between; align-items: center; margin-bottom: 22px; gap: 10px; }
        .nav-arrow-btn   { background: rgba(28,10,56,.9); border: 1.5px solid #d884ff; color: #fff; padding: 11px 20px; border-radius: 14px; font-weight: 900; font-size: 12.5px; font-family: 'Fira Code', monospace; cursor: pointer; transition: .3s; white-space: nowrap; }
        .nav-arrow-btn:hover { background: #d884ff; color: #070210; box-shadow: 0 0 25px #d884ff; }
        .week-pill-scroller{ display: flex; gap: 9px; overflow-x: auto; padding: 8px 0; margin-bottom: 22px; scrollbar-width: thin; }
        .week-pill        { background: rgba(20,7,40,.75); border: 1px solid rgba(216,132,255,.28); color: #caaef5; padding: 8px 16px; border-radius: 22px; font-family: 'Fira Code', monospace; font-size: 11px; font-weight: 800; cursor: pointer; white-space: nowrap; transition: .3s; }
        .week-pill:hover, .week-pill.active-pill { background: linear-gradient(135deg,#d884ff,#ff007f); color: #fff; border-color: transparent; box-shadow: 0 0 18px rgba(216,132,255,.55); }
        .week-card        { display: none; background: rgba(18,6,36,.85); border: 1.5px solid rgba(216,132,255,.38); border-radius: 24px; padding: 30px; backdrop-filter: blur(25px); box-shadow: 0 15px 50px rgba(0,0,0,.7); }
        .week-card.active-week { display: block; animation: fadeInWeek .4s ease forwards; }
        .week-card-header { display: flex; justify-content: space-between; align-items: flex-start; margin-bottom: 26px; border-bottom: 1px solid rgba(216,132,255,.22); padding-bottom: 18px; gap: 10px; }
        .week-badge-lg    { font-family: 'Fira Code', monospace; font-size: 12.5px; font-weight: 900; color: #00f3ff; background: rgba(0,243,255,.14); border: 1px solid #00f3ff; padding: 6px 14px; border-radius: 10px; }
        .week-card-title  { font-size: 20px; font-weight: 900; color: #fff; margin-top: 6px; line-height: 1.3; }
        .week-dual-grid   { display: grid; grid-template-columns: 1fr 1fr; gap: 22px; }
        .compartment      { background: rgba(255,255,255,.025); border: 1px solid rgba(216,132,255,.22); border-radius: 18px; padding: 22px; }
        .compartment-header { display: flex; align-items: center; margin-bottom: 18px; padding-bottom: 10px; border-bottom: 1px solid rgba(255,255,255,.07); }
        .comp-title       { font-size: 14px; font-weight: 900; }
        .comp-mat         { color: #00f3ff; text-shadow: 0 0 10px rgba(0,243,255,.4); }
        .comp-tar         { color: #ff007f; text-shadow: 0 0 10px rgba(255,0,127,.4); }
        .doc-card         { background: rgba(30,11,60,.6); border: 1px solid rgba(216,132,255,.28); border-radius: 15px; padding: 18px; margin-bottom: 15px; transition: .3s; }
        .doc-card:hover   { border-color: #d884ff; transform: translateY(-2px); box-shadow: 0 6px 24px rgba(216,132,255,.25); }
        .doc-title        { font-size: 14px; font-weight: 800; color: #fff; margin-bottom: 6px; }
        .doc-desc         { font-size: 12.5px; color: #d2bfec; margin-bottom: 14px; line-height: 1.45; }
        .doc-actions      { display: flex; gap: 9px; align-items: center; flex-wrap: wrap; }
        .btn-view { background: rgba(0,243,255,.16); border: 1px solid #00f3ff; color: #00f3ff; padding: 7px 14px; border-radius: 9px; font-size: 11px; font-weight: 800; cursor: pointer; font-family: 'Fira Code', monospace; transition: .2s; }
        .btn-view:hover { background: #00f3ff; color: #070210; }
        .btn-down { background: rgba(216,132,255,.16); border: 1px solid #d884ff; color: #d884ff; padding: 7px 14px; border-radius: 9px; font-size: 11px; font-weight: 800; text-decoration: none; font-family: 'Fira Code', monospace; transition: .2s; }
        .btn-down:hover { background: #d884ff; color: #070210; }
        .btn-del  { background: rgba(255,0,80,.18); border: 1px solid #ff0055; color: #ff6688; padding: 7px 12px; border-radius: 9px; font-size: 11.5px; cursor: pointer; margin-left: auto; text-decoration: none; transition: .2s; }
        .btn-del:hover { background: #ff0055; color: #fff; }
        .empty-slot { padding: 28px; text-align: center; border: 1.5px dashed rgba(216,132,255,.2); border-radius: 16px; color: #957eb5; font-family: 'Fira Code', monospace; font-size: 12px; }

        /* ── CONTACTO ── */
        .contact-hub-grid { display: grid; grid-template-columns: 1.2fr 1.3fr; gap: 26px; margin-top: 12px; }
        .student-id-card  { background: linear-gradient(135deg,rgba(28,9,56,.95) 0%,rgba(14,4,30,.95) 100%); border: 2px solid #ff007f; border-radius: 24px; padding: 28px; position: relative; overflow: hidden; box-shadow: 0 0 50px rgba(255,0,127,.35); }
        .student-id-card::before { content: ''; position: absolute; inset: 0; background: linear-gradient(125deg,transparent 30%,rgba(216,132,255,.15) 45%,rgba(0,243,255,.15) 55%,transparent 70%); pointer-events: none; animation: hologramScan 6s infinite linear; }
        .id-header        { display: flex; justify-content: space-between; align-items: center; border-bottom: 1.5px solid rgba(216,132,255,.3); padding-bottom: 14px; margin-bottom: 20px; }
        .id-chip          { width: 42px; height: 32px; background: linear-gradient(135deg,#ffd700,#ff8800); border-radius: 6px; box-shadow: 0 0 15px rgba(255,215,0,.6); position: relative; }
        .id-chip::after   { content: ''; position: absolute; top: 8px; left: 0; right: 0; height: 1px; background: #885500; }
        .id-body          { display: flex; gap: 20px; align-items: center; margin-bottom: 22px; }
        .id-photo         { width: 95px; height: 115px; border-radius: 18px; border: 2px solid #00f3ff; background: radial-gradient(circle,#311059,#070210); display: flex; align-items: center; justify-content: center; box-shadow: 0 0 25px rgba(0,243,255,.4); flex-shrink: 0; position: relative; overflow: hidden; }
        .id-photo-badge   { position: absolute; bottom: 4px; font-size: 8.5px; background: #00f3ff; color: #000; font-family: 'Fira Code', monospace; font-weight: 900; padding: 2px 6px; border-radius: 8px; }
        .id-details       { flex: 1; }
        .id-name          { font-size: 20px; font-weight: 900; color: #fff; text-shadow: 0 0 12px rgba(216,132,255,.5); margin-bottom: 4px; line-height: 1.2; }
        .id-spec          { font-family: 'Fira Code', monospace; font-size: 11.5px; color: #00f3ff; margin-bottom: 8px; font-weight: 700; }
        .id-code          { font-family: 'Fira Code', monospace; font-size: 11px; color: #d8bbf7; background: rgba(255,255,255,.04); padding: 4px 8px; border-radius: 6px; display: inline-block; }
        .digital-cert-seal{ background: rgba(0,243,255,.08); border: 1.5px solid #00f3ff; border-radius: 14px; padding: 14px; margin-top: 16px; text-align: center; box-shadow: 0 0 20px rgba(0,243,255,.25); }
        .contact-links-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 16px; margin-top: 16px; }
        .social-card      { background: rgba(24,8,46,.85); border: 1.5px solid rgba(216,132,255,.25); border-radius: 18px; padding: 20px; transition: .3s; display: flex; flex-direction: column; justify-content: space-between; text-decoration: none; color: inherit; }
        .social-card:hover{ border-color: #00f3ff; transform: translateY(-4px); box-shadow: 0 12px 30px rgba(0,243,255,.25); filter: brightness(1.1); }
        .social-head      { display: flex; align-items: center; gap: 12px; margin-bottom: 12px; }
        .social-icon      { font-size: 28px; filter: drop-shadow(0 0 10px rgba(216,132,255,.7)); }
        .social-title     { font-size: 14px; font-weight: 900; color: #fff; }
        .social-tag       { font-size: 10px; font-family: 'Fira Code', monospace; color: #00f3ff; text-transform: uppercase; }
        .social-desc      { font-size: 12px; color: #d0bbf2; line-height: 1.4; margin-bottom: 12px; }
        .social-action    { font-family: 'Fira Code', monospace; font-size: 11px; font-weight: 800; color: #ff007f; }

        /* ── MODALES ── */
        .cyber-modal  { position: fixed; inset: 0; background: rgba(5,2,12,.88); backdrop-filter: blur(22px); z-index: 99999; display: flex; align-items: center; justify-content: center; padding: 15px; }
        .modal-dialog { background: rgba(18,6,36,.96); border: 1.5px solid #d884ff; border-radius: 26px; padding: 28px; width: 100%; max-width: 1050px; box-shadow: 0 0 60px rgba(216,132,255,.45); }
        .modal-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 20px; border-bottom: 1px solid rgba(216,132,255,.25); padding-bottom: 12px; }
        .modal-title  { font-size: 16px; font-weight: 900; color: #00f3ff; font-family: 'Fira Code', monospace; }
        .modal-close  { background: rgba(255,0,80,.2); border: 1px solid #ff0055; color: #ff6688; padding: 7px 14px; border-radius: 9px; cursor: pointer; font-weight: 800; font-size: 12.5px; }

        /* ── FLOR-CHAN ANIME MASCOT ── */
        #cyberCatContainer { 
            position: fixed; 
            bottom: 25px; 
            right: 25px; 
            z-index: 99998; 
            cursor: pointer; 
            display: flex; 
            flex-direction: column; 
            align-items: center; 
            transition: transform .3s ease; 
            animation: animeFloatIdle 3.2s ease-in-out infinite alternate;
        }
        #cyberCatContainer:hover { 
            transform: scale(1.15) translateY(-8px); 
        }
        @keyframes animeFloatIdle {
            0%   { transform: translateY(0px) rotate(0deg); }
            50%  { transform: translateY(-8px) rotate(1.2deg); }
            100% { transform: translateY(0px) rotate(0deg); }
        }
        @keyframes animeEyeBlink {
            0%, 92%, 100% { transform: scaleY(1); }
            96% { transform: scaleY(0.08); }
        }
        @keyframes animeHairSwayL {
            0%, 100% { transform: rotate(0deg); }
            50% { transform: rotate(-4deg); }
        }
        @keyframes animeHairSwayR {
            0%, 100% { transform: rotate(0deg); }
            50% { transform: rotate(4deg); }
        }
        @keyframes animeSparkleGlow {
            0%, 100% { opacity: 0.4; transform: scale(0.9); }
            50% { opacity: 1; transform: scale(1.15); filter: drop-shadow(0 0 8px #ff77aa); }
        }
        .cat-bubble { 
            background: rgba(28, 8, 36, 0.94); 
            border: 1.5px solid var(--accent-pink); 
            color: #fff0f7; 
            font-family: 'Plus Jakarta Sans', sans-serif; 
            font-size: 11px; 
            font-weight: 800; 
            padding: 6px 14px; 
            border-radius: 16px; 
            margin-bottom: 8px; 
            box-shadow: 0 0 20px rgba(255, 102, 178, 0.5); 
            animation: bubbleBounce 2s ease-in-out infinite alternate; 
            pointer-events: none; 
            white-space: nowrap; 
            display: flex;
            align-items: center;
            gap: 6px;
        }
        .anime-mascot-sprite { 
            width: 100px; 
            height: 100px; 
            filter: drop-shadow(0 0 20px rgba(255, 102, 178, 0.75)); 
            transition: transform 0.2s ease;
        }
        #michiWindow { position: fixed; bottom: 115px; right: 25px; width: 410px; max-height: 580px; height: 80vh; background: rgba(18,6,36,.96); border: 1.5px solid #d884ff; border-radius: 24px; box-shadow: 0 15px 60px rgba(0,0,0,.85); backdrop-filter: blur(25px); z-index: 99999; display: none; flex-direction: column; overflow: hidden; }
        .michi-head  { background: rgba(30,10,60,.85); border-bottom: 1px solid rgba(216,132,255,.25); padding: 14px 18px; display: flex; justify-content: space-between; align-items: center; }
        .michi-title { font-size: 13.5px; font-weight: 900; color: #ff77aa; font-family: 'Fira Code', monospace; display: flex; align-items: center; gap: 8px; }
        .michi-body  { flex: 1; padding: 15px; overflow-y: auto; display: flex; flex-direction: column; gap: 12px; }
        .michi-msg   { max-width: 88%; padding: 11px 15px; border-radius: 14px; font-size: 12.5px; line-height: 1.5; }
        .msg-bot     { background: rgba(216,132,255,.14); border: 1px solid rgba(216,132,255,.32); color: #f5edff; align-self: flex-start; }
        .msg-user    { background: linear-gradient(135deg,#d884ff,#ff007f); color: #fff; align-self: flex-end; font-weight: 700; }
        .michi-chips { display: flex; gap: 6px; overflow-x: auto; padding: 8px 12px; border-top: 1px solid rgba(255,255,255,.06); }
        .m-chip      { background: rgba(255,255,255,.04); border: 1px solid rgba(216,132,255,.25); padding: 5px 10px; border-radius: 12px; font-size: 10px; font-family: 'Fira Code', monospace; color: #d884ff; cursor: pointer; white-space: nowrap; }
        .m-chip:hover{ border-color: #00f3ff; color: #00f3ff; }
        .michi-input-box { padding: 10px 12px; border-top: 1px solid rgba(216,132,255,.22); display: flex; gap: 8px; background: rgba(10,3,20,.6); }
        .michi-input { flex: 1; background: rgba(28,10,56,.85); border: 1px solid rgba(216,132,255,.3); border-radius: 10px; padding: 10px 12px; color: #fff; font-size: 12px; outline: none; }
        .michi-send-btn { background: #ff007f; border: none; border-radius: 10px; color: #fff; padding: 0 14px; font-size: 12px; cursor: pointer; font-weight: 800; }

        /* ── BOTÓN ACCESO ALUMNA (MODIFICAR) ── */
        .btn-alumna-login {
            background: linear-gradient(135deg, #d884ff 0%, #ff007f 100%);
            color: #fff !important;
            padding: 8px 18px;
            border-radius: 12px;
            font-family: 'Fira Code', monospace;
            font-size: 11.5px;
            font-weight: 800;
            text-decoration: none;
            box-shadow: 0 0 20px rgba(255, 0, 127, 0.6);
            transition: 0.3s;
            white-space: nowrap;
            display: inline-flex;
            align-items: center;
            gap: 6px;
        }
        .btn-alumna-login:hover {
            transform: scale(1.06);
            box-shadow: 0 0 35px #ff007f;
            filter: brightness(1.15);
        }

        /* ── SELECTOR DE TEMAS HUD ── */
        .theme-switcher-container { position: relative; display: inline-block; }
        .btn-theme-trigger {
            background: rgba(255, 255, 255, 0.06);
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
        }
        .btn-theme-trigger:hover {
            border-color: var(--accent-cyan);
            background: rgba(255, 255, 255, 0.12);
            box-shadow: 0 0 15px var(--accent-cyan);
            transform: translateY(-1px);
        }
        .theme-dropdown-menu {
            position: absolute;
            top: calc(100% + 10px);
            right: 0;
            background: var(--bg-surface-solid);
            border: 1.5px solid var(--border-color);
            border-radius: 18px;
            padding: 10px;
            min-width: 240px;
            box-shadow: var(--card-shadow);
            z-index: 10001;
            display: none;
            flex-direction: column;
            gap: 5px;
            animation: fadeInWeek .2s ease;
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
            border-radius: 12px;
            padding: 8px 12px;
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
            transform: translateX(3px);
        }
        .theme-opt-btn.active {
            background: rgba(0, 243, 255, 0.12);
            border-color: var(--accent-cyan);
        }
        .theme-dot {
            width: 18px;
            height: 18px;
            border-radius: 50%;
            flex-shrink: 0;
            box-shadow: 0 0 8px rgba(0,0,0,0.4);
        }
        .theme-info {
            display: flex;
            flex-direction: column;
            flex: 1;
        }
        .theme-name {
            font-size: 12px;
            font-weight: 800;
            color: var(--text-primary);
        }
        .theme-desc {
            font-size: 9.5px;
            font-family: 'Fira Code', monospace;
            color: var(--text-secondary);
        }
        .theme-check {
            font-size: 11px;
            color: var(--accent-cyan);
            display: none;
        }
        .theme-opt-btn.active .theme-check {
            display: inline-block;
        }

        /* ── REPRODUCTOR DE MÚSICA HUD ── */
        .btn-music-pill {
            background: rgba(255, 255, 255, 0.06);
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
            gap: 8px;
            white-space: nowrap;
        }
        .btn-music-pill:hover {
            border-color: var(--accent-cyan);
            background: rgba(255, 255, 255, 0.12);
            box-shadow: 0 0 16px var(--accent-cyan);
        }
        .btn-music-pill.playing {
            border-color: var(--accent-cyan);
            background: rgba(0, 243, 255, 0.15);
            color: var(--accent-cyan);
            box-shadow: 0 0 20px rgba(0, 243, 255, 0.4);
        }
        .music-bars-eq {
            display: flex;
            align-items: flex-end;
            gap: 2.5px;
            height: 14px;
            width: 14px;
        }
        .eq-bar {
            width: 2.5px;
            background: var(--text-muted);
            border-radius: 2px;
            height: 4px;
            transition: height .2s ease;
        }
        .btn-music-pill.playing .eq-bar {
            background: var(--accent-cyan);
            animation: bounceBar 0.8s ease-in-out infinite alternate;
        }
        .btn-music-pill.playing .bar-1 { animation-delay: 0.0s; height: 10px; }
        .btn-music-pill.playing .bar-2 { animation-delay: 0.2s; height: 14px; }
        .btn-music-pill.playing .bar-3 { animation-delay: 0.4s; height: 8px; }
        .btn-music-pill.playing .bar-4 { animation-delay: 0.1s; height: 12px; }
        @keyframes bounceBar {
            0%   { height: 3px; }
            100% { height: 14px; }
        }
        .volume-slider-wrapper {
            display: inline-flex;
            align-items: center;
            gap: 5px;
            background: rgba(255,255,255,0.04);
            border: 1px solid var(--border-color);
            padding: 5px 8px;
            border-radius: 10px;
        }
        .volume-slider-wrapper input[type=range] {
            width: 50px;
            height: 4px;
            accent-color: var(--accent-cyan);
            cursor: pointer;
        }

        /* ── BOTÓN SIGUIENTE PISTA DE MÚSICA HUD ── */
        .btn-track-pill {
            background: rgba(255, 255, 255, 0.06);
            border: 1.5px solid var(--border-color);
            color: var(--text-primary);
            padding: 8px 12px;
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
        }
        .btn-track-pill:hover {
            border-color: var(--border-accent);
            background: rgba(255, 255, 255, 0.12);
            box-shadow: 0 0 15px var(--accent-cyan);
            transform: translateY(-1px);
        }

        /* ── BOTÓN DESTACADO ACCESO // LOGIN HUD ── */
        .btn-acceso-top {
            background: linear-gradient(135deg, #ff007f 0%, #d884ff 50%, #00f3ff 100%);
            background-size: 200% auto;
            color: #fff !important;
            border: none;
            padding: 8px 18px;
            border-radius: 12px;
            font-family: 'Fira Code', monospace;
            font-size: 11.5px;
            font-weight: 900;
            cursor: pointer;
            box-shadow: 0 0 20px rgba(255, 0, 127, 0.65);
            transition: all 0.3s ease;
            display: inline-flex;
            align-items: center;
            gap: 7px;
            white-space: nowrap;
            letter-spacing: 0.8px;
            animation: glowPulse 3s infinite;
        }
        .btn-acceso-top:hover {
            transform: scale(1.08) translateY(-1px);
            box-shadow: 0 0 35px #00f3ff, 0 0 45px #ff007f;
            filter: brightness(1.2);
        }
        @keyframes glowPulse {
            0%, 100% { box-shadow: 0 0 18px rgba(255, 0, 127, 0.55); }
            50%      { box-shadow: 0 0 28px rgba(0, 243, 255, 0.7); }
        }

        /* ── EFECTO 3D TILT SUAVE PARA TARJETAS ── */
        .cyber-card, .docente-card-pro, .student-id-card, .unit-card, .week-card {
            transition: transform 0.25s cubic-bezier(0.25, 0.46, 0.45, 0.94), box-shadow 0.25s ease, border-color 0.25s ease;
            will-change: transform;
            transform-style: preserve-3d;
        }
    </style>
</head>
<body>
<canvas id="bgCanvas"></canvas>
<audio id="bgMusicPlayer" src="<%= ctx %>/sakura_lofi.mp3" loop preload="auto"></audio>

<%-- ── CYBER LOADER (solo en primer login) ─────────────── --%>
<% if (justLoggedIn) { %>
<div id="cyberLoader" onclick="this.style.opacity='0'; setTimeout(() => this.remove(), 250);" style="cursor:pointer;" title="Clic para omitir y entrar">
    <div class="loader-card">
        <img src="<%= ctx %>/IMG/image.png" alt="UPLA"
             style="height:75px;filter:drop-shadow(0 0 20px #d884ff);margin-bottom:10px;"
             onerror="this.src='https://upload.wikimedia.org/wikipedia/commons/thumb/e/e0/Logo_Universidad_Peruana_Los_Andes.png/640px-Logo_Universidad_Peruana_Los_Andes.png'">
        <div style="font-family:'Fira Code',monospace;font-size:11.5px;color:#d884ff;letter-spacing:2px;font-weight:800;">SISTEMA ARQUITECTÓNICO UPLA 2026-I</div>
        <div class="loader-pct" id="loaderPct">000%</div>
        <div class="loader-bar-bg"><div class="loader-bar-fill" id="loaderFill"></div></div>
        <div class="loader-status" id="loaderStatus">SINCRONIZANDO KERNEL CIBERNÉTICO...</div>
        <div class="loader-welcome" id="loaderWelcome">
            <% if (esAdmin) { %>¡BIENVENIDA, ALUMNA TITULAR <%= nombreAlumna.toUpperCase() %>!
            <% } else { %>¡BIENVENIDO, VISITANTE ACADÉMICO / AUDITOR!<% } %>
        </div>
    </div>
</div>
<% } %>

<%-- ── HUD SUPERIOR ──────────────────────────────────────── --%>
<header class="hud-top">
    <div class="hud-left">
        <img src="<%= ctx %>/IMG/image.png" alt="Logo UPLA" class="hud-logo"
             onerror="this.src='https://upload.wikimedia.org/wikipedia/commons/thumb/e/e0/Logo_Universidad_Peruana_Los_Andes.png/640px-Logo_Universidad_Peruana_Los_Andes.png'">
        <div>
            <div class="hud-brand">UNIVERSIDAD PERUANA LOS ANDES</div>
            <div class="hud-facultad">FACULTAD DE INGENIERÍA // EPISC &bull; ARQUITECTURA DE SOFTWARE 2026-I</div>
        </div>
    </div>
    <div class="telemetry-hud">
        <div class="hud-stat"><span class="pulse-green"></span>ARCHIVOS EN BD: <b id="hudTotalArchivos"><%= totalArchivos %></b></div>
        <div class="hud-stat">DOCUMENTOS: <b><%= totalArchivos %></b></div>

        <!-- REPRODUCTOR DE MÚSICA HUD (MELODÍAS ANIME & LO-FI) -->
        <div class="music-hud-container" style="display:inline-flex; align-items:center; gap:6px;">
            <button type="button" class="btn-music-pill" id="musicPillBtn" onclick="toggleMusic(event)" title="Reproducir o pausar música melódica anime">
                <div class="music-bars-eq" id="musicEqBars">
                    <span class="eq-bar bar-1"></span>
                    <span class="eq-bar bar-2"></span>
                    <span class="eq-bar bar-3"></span>
                    <span class="eq-bar bar-4"></span>
                </div>
                <i class="fas fa-play" id="musicPlayIcon"></i>
                <span id="musicBtnLabel">MÚSICA</span>
            </button>
            <button type="button" class="btn-track-pill" id="trackNextBtn" onclick="nextTrack(event)" title="Cambiar a la siguiente melodía anime">
                <i class="fas fa-compact-disc" style="color:var(--accent-cyan);"></i>
                <span id="trackNameLabel">🌸 01. Sakura Piano</span>
                <i class="fas fa-step-forward" style="font-size:9px;"></i>
            </button>
            <div class="volume-slider-wrapper" title="Control de volumen">
                <i class="fas fa-volume-up" style="font-size:10px; color:var(--text-secondary);"></i>
                <input type="range" id="musicVolumeSlider" min="0" max="1" step="0.05" value="0.45" oninput="setMusicVolume(this.value)">
            </div>
        </div>

        <!-- SELECTOR DE TEMAS INNOVADORES HUD -->
        <div class="theme-switcher-container">
            <button type="button" class="btn-theme-trigger" id="themeBtn" onclick="toggleThemeMenu(event)" title="Cambiar tema visual del portafolio">
                <i class="fas fa-palette" style="color:var(--accent-cyan);"></i>
                <span id="themeBtnLabel">TEMAS</span>
                <i class="fas fa-chevron-down" style="font-size:9px;"></i>
            </button>
            <div class="theme-dropdown-menu" id="themeDropdownMenu">
                <div class="theme-dropdown-header">// TEMAS INNOVADORES &bull; ESTILO ANIME</div>
                <button type="button" class="theme-opt-btn" data-theme-val="sakura" onclick="setTheme('sakura')">
                    <span class="theme-dot" style="background: linear-gradient(135deg, #ff77aa, #ff1493);"></span>
                    <div class="theme-info">
                        <span class="theme-name">🌸 Anime Sakura</span>
                        <span class="theme-desc">Cardcaptor &bull; Pétalos de cerezo 3D en el viento</span>
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
                        <span class="theme-desc">Demon Slayer &bull; Katana esmeralda y brasas de fuego</span>
                    </div>
                    <i class="fas fa-check theme-check"></i>
                </button>
                <button type="button" class="theme-opt-btn" data-theme-val="lofi" onclick="setTheme('lofi')">
                    <span class="theme-dot" style="background: linear-gradient(135deg, #ffaa44, #ff5533);"></span>
                    <div class="theme-info">
                        <span class="theme-name">☕ Ghibli Cafe</span>
                        <span class="theme-desc">Studio Ghibli &bull; Atardecer cálido, polvo mágico y lofi</span>
                    </div>
                    <i class="fas fa-check theme-check"></i>
                </button>
                <button type="button" class="theme-opt-btn" data-theme-val="cyber" onclick="setTheme('cyber')">
                    <span class="theme-dot" style="background: linear-gradient(135deg, #00f3ff, #ff007f);"></span>
                    <div class="theme-info">
                        <span class="theme-name">⚡ Cyberpunk 2077</span>
                        <span class="theme-desc">Neo Tokyo &bull; Edgerunners, láseres y meteoros</span>
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

        <% if (esAdmin) { %>
            <span class="user-badge-admin">&#127800; ALUMNA TITULAR: <%= nombreAlumna %></span>
            <span class="hud-stat" style="border-color:#ff007f; color:#ff80df;" title="Privilegios de subida y edición activos">
                &#10024; MODO EDICIÓN ACTIVO
            </span>
            <a href="<%= ctx %>/logout" class="btn-exit" title="Cerrar sesión">[ CERRAR SESIÓN ]</a>
        <% } else { %>
            <span class="user-badge-est" title="Navegación libre para docentes, auditores y visitantes">&#128065;&#65039; MODO AUDITOR</span>
            <button type="button" class="btn-acceso-top" onclick="openAlumnaModal(event)" title="Acceso exclusivo para Flor Xiomara Medina Salazar (Modificar, Subir Tareas y Administrar)">
                <i class="fas fa-lock"></i> 🔐 ACCESO
            </button>
        <% } %>
    </div>
</header>

<%-- ── ALERTAS ──────────────────────────────────────────── --%>
<% if ("upload_ok".equals(msg)) { %>
    <div class="alert-top alert-ok">&#10003; DOCUMENTO PUBLICADO CON ÉXITO Y REGISTRADO EN EL PORTAFOLIO.</div>
<% } else if ("del_ok".equals(msg)) { %>
    <div class="alert-top alert-del">&#10003; REGISTRO Y ARCHIVO ELIMINADOS CORRECTAMENTE.</div>
<% } else if ("perfil_actualizado".equals(msg)) { %>
    <div class="alert-top alert-ok">&#10003; PERFIL DE ALUMNA ACTUALIZADO CORRECTAMENTE.</div>
<% } else if ("msg_enviado".equals(msg)) { %>
    <div class="alert-top alert-msg">&#10003; MENSAJE ENVIADO AL BUZÓN INSTITUCIONAL DE FLOR XIOMARA.</div>
<% } %>

<%-- ── PESTAÑAS ──────────────────────────────────────────── --%>
<div class="tabs-bar">
    <a href="<%= ctx %>/portafolio?tab=presentacion"
       class="tab-link <%= "presentacion".equals(activeTab) ? "tab-active" : "tab-inactive" %>">
       &#127800; 01. Presentación de la Estudiante
    </a>
    <a href="<%= ctx %>/portafolio?tab=archivos"
       class="tab-link <%= "archivos".equals(activeTab) ? "tab-active" : "tab-inactive" %>">
       &#128194; 02. Portafolio Semanal &amp; Tareas
    </a>
    <a href="<%= ctx %>/portafolio?tab=contacto"
       class="tab-link <%= "contacto".equals(activeTab) ? "tab-active" : "tab-inactive" %>">
       &#9889; 03. Contacto &amp; Redes
    </a>
</div>

<main class="main-content">

<%-- ═══════════════════════════════════════════════════════
     TAB 01: PRESENTACIÓN
═══════════════════════════════════════════════════════ --%>
<% if ("presentacion".equals(activeTab)) { %>

    <%-- Hero --%>
    <section class="hero-showcase">
        <div class="hero-left-content">
            <span class="neon-sub">// PORTAFOLIO ACADÉMICO DIGITAL OFICIAL</span>
            <h1 class="meteor-glow" style="font-size:32px;margin:10px 0 8px;">ARQUITECTURA DE SOFTWARE 2026-I</h1>
            <p style="color:#cbd5e1;font-size:13.5px;line-height:1.65;max-width:820px;">
                Evidencias de aprendizaje, requerimientos de calidad (ISO/IEC 25010), modelos de 4+1 vistas,
                diseño por capas, APIs RESTful en Jakarta EE y persistencia relacional MySQL.
            </p>
            <div class="hero-tags-row">
                <div class="hero-tag-item">&#127963; Código: <b>332181</b></div>
                <div class="hero-tag-item">&#128203; Plan: <b>2022</b></div>
                <div class="hero-tag-item">&#11088; Créditos: <b>02</b></div>
                <div class="hero-tag-item">&#9201; Horas: <b>04 Prácticas</b></div>
                <div class="hero-tag-item">&#128205; Modalidad: <b>Presencial</b></div>
                <div class="hero-tag-item">&#127891; Facultad: <b>Ingeniería // EPISC</b></div>
            </div>
        </div>
        <div class="upla-3d-box">
            <div class="upla-3d-shield">
                <div class="upla-3d-inner">
                    <img src="<%= ctx %>/IMG/image.png" alt="UPLA"
                         onerror="this.src='https://upload.wikimedia.org/wikipedia/commons/thumb/e/e0/Logo_Universidad_Peruana_Los_Andes.png/640px-Logo_Universidad_Peruana_Los_Andes.png'">
                </div>
            </div>
            <div class="upla-3d-caption">UPLA &bull; HUANCAYO</div>
        </div>
    </section>

    <%-- Dossier: Alumna + Docente --%>
    <div class="dossier-grid">

        <%-- Alumna Titular --%>
        <div class="cyber-card">
            <div class="student-header">
                <div class="avatar-frame">
                    <img src="<%= ctx %>/IMG/IMGS.jpeg" alt="Foto de <%= nombreAlumna %>"
                         style="width:100%;height:100%;object-fit:cover;filter:drop-shadow(0 0 8px rgba(255,0,127,.6));"
                         onerror="this.style.display='none';this.parentNode.insertAdjacentHTML('beforeend','<span style=font-size:42px>&#127800;</span>');">
                    <div class="chip-badge">AUTORA</div>
                </div>
                <div>
                    <div class="student-title">// ALUMNA TITULAR &bull; INGENIERÍA DE SISTEMAS</div>
                    <h2 class="student-name"><%= nombreAlumna %></h2>
                    <div style="font-family:'Fira Code',monospace;font-size:12px;color:#cba6f7;">UNIVERSIDAD PERUANA LOS ANDES &bull; HUANCAYO</div>
                </div>
            </div>
            <div class="meta-list">
                <div class="meta-item"><div class="meta-lbl">Carrera Profesional</div><div class="meta-val">Ingeniería de Sistemas y Computación</div></div>
                <div class="meta-item"><div class="meta-lbl">Correo Institucional</div><div class="meta-val" style="color:#00f3ff;">s01269h@upla.edu.pe</div></div>
                <div class="meta-item"><div class="meta-lbl">Semestre Académico</div><div class="meta-val">2026-I &bull; Plan de Estudios 2022</div></div>
                <div class="meta-item"><div class="meta-lbl">Rol en el Sistema</div><div class="meta-val" style="color:#ff007f;">Alumna Titular / Autora</div></div>
            </div>
            <% if (esAdmin) { %>
                <button class="edit-profile-btn" onclick="document.getElementById('editModal').style.display='flex';">&#9999;&#65039; Editar Mi Nombre</button>
            <% } else { %>
                <div class="readonly-tag">&#128274; Modo de solo lectura (Auditoría Académica UPLA)</div>
            <% } %>
        </div>

        <%-- Docente --%>
        <div class="cyber-card docente-card-pro">
            <div class="docente-header">
                <div class="docente-avatar-frame">&#128104;&#8205;&#127979;<div class="chip-badge" style="background:#a855f7;box-shadow:0 0 10px #a855f7;">CÁTEDRA</div></div>
                <div>
                    <div style="font-family:'Fira Code',monospace;font-size:11px;color:#c084fc;font-weight:800;letter-spacing:1px;">// DIRECCIÓN DOCENTE &bull; CÁTEDRA DE ARQUITECTURA</div>
                    <h2 style="font-size:23px;font-weight:900;color:#fff;text-shadow:0 0 15px rgba(168,85,247,.7);margin:3px 0;">Mg. Raúl Enrique Fernández Bejarano</h2>
                    <div style="font-family:'Fira Code',monospace;font-size:11.5px;color:#00f3ff;">DOCENTE TITULAR DE LA ASIGNATURA</div>
                </div>
            </div>
            <div class="docente-spec-grid">
                <div class="docente-spec-box"><div class="meta-lbl" style="color:#c084fc;">Correo Oficial Cátedra</div><div class="meta-val" style="color:#00f3ff;font-size:12.5px;word-break:break-all;">d.rfernandezb@ms.upla.edu.pe</div></div>
                <div class="docente-spec-box"><div class="meta-lbl" style="color:#c084fc;">Código &amp; Créditos</div><div class="meta-val">332181 &bull; 02 Créditos</div></div>
                <div class="docente-spec-box"><div class="meta-lbl" style="color:#c084fc;">Carga Horaria Semanal</div><div class="meta-val">04 Horas Prácticas</div></div>
                <div class="docente-spec-box"><div class="meta-lbl" style="color:#c084fc;">Semestre Académico</div><div class="meta-val">2026-I (06 Abr - 26 Jul 2026)</div></div>
                <div class="docente-spec-box"><div class="meta-lbl" style="color:#c084fc;">Modalidad &amp; Facultad</div><div class="meta-val">Presencial &bull; Pabellón EPISC</div></div>
                <div class="docente-spec-box"><div class="meta-lbl" style="color:#c084fc;">Especialidad Docente</div><div class="meta-val">Arquitectura Cloud &amp; Microservicios</div></div>
            </div>
            <a href="mailto:d.rfernandezb@ms.upla.edu.pe" class="btn-docente-mail">&#9993;&#65039; Enviar Consulta al Mg. Raúl Fernández</a>
        </div>
    </div>

    <%-- Sumilla --%>
    <div class="cyber-card" style="margin-bottom:26px;">
        <span class="neon-sub">// SÍLABO OFICIAL UPLA &bull; PLAN 2022</span>
        <h2 class="neon-title" style="font-size:22px;margin:6px 0 16px;">Sumilla y Competencia General</h2>
        <div style="display:grid;grid-template-columns:1fr 1fr;gap:20px;">
            <div style="background:rgba(255,255,255,.025);border:1px solid rgba(216,132,255,.2);border-radius:16px;padding:20px;">
                <h4 style="color:#ff007f;font-family:'Fira Code',monospace;font-size:12px;margin-bottom:8px;">&#128214; SUMILLA OFICIAL DE LA ASIGNATURA</h4>
                <p style="font-size:12.5px;line-height:1.65;color:#d2bdef;">Asignatura de naturaleza práctica orientada a comprender y formular soluciones de arquitectura de software bajo estándares internacionales (IEEE 1471, ISO/IEC 25010). Capacita en diseño por componentes, desacoplamiento, comunicación mediante APIs empresariales y adopción de frameworks modernos.</p>
            </div>
            <div style="background:rgba(255,255,255,.025);border:1px solid rgba(216,132,255,.2);border-radius:16px;padding:20px;">
                <h4 style="color:#00f3ff;font-family:'Fira Code',monospace;font-size:12px;margin-bottom:8px;">&#127919; COMPETENCIA &amp; LOGRO GENERAL</h4>
                <p style="font-size:12.5px;line-height:1.65;color:#d2bdef;">Diseña, evalúa e implementa arquitecturas de software robustas, escalables y seguras utilizando POO, modelos 4+1 vistas de Kruchten, persistencia relacional y despliegues empresariales para resolver problemas tecnológicos contextualizados.</p>
            </div>
        </div>
    </div>

    <%-- Unidades / Reactores --%>
    <div class="cyber-card">
        <span class="neon-sub">// PROGRAMACIÓN DE CAPACIDADES</span>
        <h2 class="neon-title" style="font-size:22px;margin:6px 0 16px;">Reactores de Avance Curricular (4 Unidades)</h2>
        <div class="units-grid">
            <div class="unit-card">
                <div class="unit-badge">UNIDAD I &bull; SEM 1-4</div>
                <div class="unit-title">Fundamentos y Estándares de Arquitectura de Software</div>
                <div class="reactor-bar"><div class="reactor-fill" style="width:100%;background:#00ff88;box-shadow:0 0 10px #00ff88;"></div></div>
                <div style="font-family:'Fira Code',monospace;font-size:11px;color:#00ff88;font-weight:800;">AVANCE: 100%</div>
            </div>
            <div class="unit-card">
                <div class="unit-badge">UNIDAD II &bull; SEM 5-8</div>
                <div class="unit-title">Modelado de Arquitecturas con POO y Vistas 4+1</div>
                <div class="reactor-bar"><div class="reactor-fill" style="width:100%;background:#00f3ff;box-shadow:0 0 10px #00f3ff;"></div></div>
                <div style="font-family:'Fira Code',monospace;font-size:11px;color:#00f3ff;font-weight:800;">AVANCE: 100%</div>
            </div>
            <div class="unit-card">
                <div class="unit-badge">UNIDAD III &bull; SEM 9-12</div>
                <div class="unit-title">Comunicación, Integración y Servicios Web REST</div>
                <div class="reactor-bar"><div class="reactor-fill" style="width:75%;background:#d884ff;box-shadow:0 0 10px #d884ff;"></div></div>
                <div style="font-family:'Fira Code',monospace;font-size:11px;color:#d884ff;font-weight:800;">AVANCE: 75%</div>
            </div>
            <div class="unit-card">
                <div class="unit-badge">UNIDAD IV &bull; SEM 13-16</div>
                <div class="unit-title">Frameworks Modernos y Despliegue en Cloud Azure</div>
                <div class="reactor-bar"><div class="reactor-fill" style="width:50%;background:#ff007f;box-shadow:0 0 10px #ff007f;"></div></div>
                <div style="font-family:'Fira Code',monospace;font-size:11px;color:#ff007f;font-weight:800;">AVANCE: 50%</div>
            </div>
        </div>
    </div>

<% } /* fin tab presentacion */ %>

<%-- ═══════════════════════════════════════════════════════
     TAB 02: PORTAFOLIO SEMANAL & TAREAS
═══════════════════════════════════════════════════════ --%>
<% if ("archivos".equals(activeTab)) { %>

    <%-- Formulario de subida (solo admin) --%>
    <% if (esAdmin) { %>
    <div class="upload-console">
        <div class="console-header">
            <div class="console-title">&#10133; PUBLICAR MATERIAL O TAREA</div>
            <span class="neon-sub">// TRANSMISIÓN EN VIVO A BASE DE DATOS</span>
        </div>
        <form action="<%= ctx %>/clases/crear" method="POST" enctype="multipart/form-data">
            <div class="form-grid">
                <div>
                    <label style="font-size:11px;font-family:'Fira Code',monospace;color:#d884ff;display:block;margin-bottom:5px;font-weight:700;">SEMANA ACADÉMICA (N° o texto):</label>
                    <input type="text" name="semana" id="formSemanaInput" class="cyber-input"
                           placeholder="Ej: 1, 2, 3 o Semana 1" value="1" required>
                </div>
                <div>
                    <label style="font-size:11px;font-family:'Fira Code',monospace;color:#d884ff;display:block;margin-bottom:5px;font-weight:700;">TÍTULO DEL TEMA / TAREA:</label>
                    <input type="text" name="titulo" class="cyber-input"
                           placeholder="Escribe el tema o título que dictó el Ingeniero..." required>
                </div>
            </div>
            <div style="margin-top:14px;">
                <label style="font-size:11px;font-family:'Fira Code',monospace;color:#d884ff;display:block;margin-bottom:5px;font-weight:700;">CLASIFICACIÓN DEL ARCHIVO:</label>
                <div class="type-selector">
                    <label class="radio-btn-label"><input type="radio" name="tipo" value="MATERIAL" checked> &#128218; Material de Clase (Teoría / Diapositivas)</label>
                    <label class="radio-btn-label"><input type="radio" name="tipo" value="TAREA"> &#128221; Tarea Desarrollada (Práctica / Informe)</label>
                </div>
            </div>
            <div style="margin-top:14px;">
                <label style="font-size:11px;font-family:'Fira Code',monospace;color:#d884ff;display:block;margin-bottom:5px;font-weight:700;">DESCRIPCIÓN DEL CONTENIDO:</label>
                <textarea name="descripcion" rows="2" class="cyber-textarea"
                          placeholder="Resumen del material o solución de la tarea..." required></textarea>
            </div>
            <div class="cyber-dropzone" onclick="document.getElementById('fileInput').click();">
                <div class="dropzone-icon">&#128228;</div>
                <div class="dropzone-text" id="dropzoneText">Haz clic aquí para seleccionar tu archivo</div>
                <div class="dropzone-sub">Formatos aceptados: PDF, Word (.docx), PPTX, ZIP, Imágenes</div>
                <input type="file" id="fileInput" name="archivo" style="display:none;"
                       onchange="document.getElementById('dropzoneText').innerText='&#10003; Archivo preparado: '+this.files[0].name;" required>
            </div>
            <button type="submit" class="submit-btn">&#128190; GUARDAR Y PUBLICAR EN EL PORTAFOLIO</button>
        </form>
    </div>
    <% } %>

    <%-- Carrusel de semanas --%>
    <div class="carousel-nav">
        <button class="nav-arrow-btn" onclick="changeWeek(-1)">&#9664; SEMANA ANTERIOR</button>
        <span class="neon-sub" id="carouselStatus">NAVEGANDO SEMANA <%= pad(initialSemana) %> DE 16</span>
        <button class="nav-arrow-btn" onclick="changeWeek(1)">SEMANA SIGUIENTE &#9654;</button>
    </div>

    <div class="week-pill-scroller">
    <% for (int s = 1; s <= 16; s++) { %>
        <div class="week-pill <%= s == initialSemana ? "active-pill" : "" %>"
             onclick="selectWeek(<%= s %>)" id="pill-<%= s %>">SEM <%= pad(s) %></div>
    <% } %>
    </div>

    <%-- Tarjetas por semana --%>
    <% for (int s = 1; s <= 16; s++) {
        String tituloSemana = temaDeSemana(temasSemanas, s);

        // Archivos de esta semana separados por tipo
        List<Archivo> matList = new ArrayList<>();
        List<Archivo> tarList = new ArrayList<>();
        for (Archivo a : archivos) {
            if (a.getSemana() == s) {
                if (a.esTarea()) tarList.add(a);
                else             matList.add(a);
            }
        }
    %>
    <div class="week-card <%= s == initialSemana ? "active-week" : "" %>" id="week-card-<%= s %>">
        <div class="week-card-header">
            <div>
                <span class="week-badge-lg">SEMANA <%= pad(s) %> DE 16</span>
                <h2 class="week-card-title"><%= tituloSemana %></h2>
            </div>
        </div>
        <div class="week-dual-grid">

            <%-- Compartimento MATERIAL --%>
            <div class="compartment">
                <div class="compartment-header">
                    <div class="comp-title comp-mat">&#128218; Material Oficial de Clase</div>
                </div>
                <% if (matList.isEmpty()) { %>
                    <div class="empty-slot">&#128237; Sin material de clase registrado</div>
                <% } else { for (Archivo arc : matList) {
                    String urlDown = ctx + "/archivos/descargar/" + arc.getId();
                    String urlVer  = ctx + "/archivos/ver/" + arc.getId();
                    String safeTitulo = arc.getTitulo() != null ? arc.getTitulo().replace("'", "\\'").replace("\"", "&quot;") : "Material";
                    String safeNombre = arc.getNombreArchivo() != null ? arc.getNombreArchivo().replace("'", "\\'").replace("\"", "&quot;") : "";
                    String tipoDoc = arc.esPdf() ? "pdf" : (arc.esWord() ? "word" : "doc");
                %>
                    <div class="doc-card" id="doc-card-<%= arc.getId() %>">
                        <div class="doc-title"><%= arc.getTitulo() %></div>
                        <div class="doc-desc"><%= arc.getDescripcion() %></div>
                        <div class="doc-actions">
                            <a href="<%= urlDown %>" class="btn-down" target="_blank" title="Descargar archivo a tu equipo">&#128229; Descargar</a>
                            <% if (arc.esVisualizable()) { %>
                            <button type="button" class="btn-view" onclick="openDocModal('<%= urlVer %>','<%= safeTitulo %>','<%= tipoDoc %>','<%= urlDown %>')" title="Ver en visor integrado">&#128065;&#65039; Ver <%= arc.esPdf() ? "PDF" : (arc.esWord() ? "Word" : "Doc") %></button>
                            <a href="<%= urlVer %>" target="_blank" class="btn-down" style="padding:7px 11px;border-color:#00f3ff;color:#00f3ff;" title="Abrir en pantalla completa directa">&#8599;&#65039; Pantalla Completa</a>
                            <% } %>
                            <button type="button" class="btn-del" onclick="abrirConfirmarEliminar(<%= arc.getId() %>, '<%= safeTitulo %>', <%= s %>, <%= esAdmin %>)" title="Eliminar este archivo">&#128465;&#65039; Eliminar</button>
                        </div>
                    </div>
                <% } } %>
            </div>

            <%-- Compartimento TAREA --%>
            <div class="compartment">
                <div class="compartment-header">
                    <div class="comp-title comp-tar">&#128221; Tareas &amp; Prácticas Desarrolladas</div>
                </div>
                <% if (tarList.isEmpty()) { %>
                    <div class="empty-slot">&#128237; Sin tareas desarrolladas registradas aún</div>
                <% } else { for (Archivo arc : tarList) {
                    String urlDown = ctx + "/archivos/descargar/" + arc.getId();
                    String urlVer  = ctx + "/archivos/ver/" + arc.getId();
                    String safeTitulo = arc.getTitulo() != null ? arc.getTitulo().replace("'", "\\'").replace("\"", "&quot;") : "Tarea";
                    String safeNombre = arc.getNombreArchivo() != null ? arc.getNombreArchivo().replace("'", "\\'").replace("\"", "&quot;") : "";
                    String tipoDoc = arc.esPdf() ? "pdf" : (arc.esWord() ? "word" : "doc");
                %>
                    <div class="doc-card" id="doc-card-<%= arc.getId() %>" style="border-color:rgba(255,0,127,.35);">
                        <div class="doc-title" style="color:#ff80bf;"><%= arc.getTitulo() %></div>
                        <div class="doc-desc"><%= arc.getDescripcion() %></div>
                        <div class="doc-actions">
                            <a href="<%= urlDown %>" class="btn-down" style="border-color:#ff007f;color:#ff66b2;" target="_blank" title="Descargar tarea a tu equipo">&#128229; Descargar Tarea</a>
                            <% if (arc.esVisualizable()) { %>
                            <button type="button" class="btn-view" style="border-color:#ff007f;color:#ff80df;" onclick="openDocModal('<%= urlVer %>','<%= safeTitulo %>','<%= tipoDoc %>','<%= urlDown %>')" title="Ver en visor integrado">&#128065;&#65039; Ver <%= arc.esPdf() ? "PDF" : (arc.esWord() ? "Word" : "Doc") %></button>
                            <a href="<%= urlVer %>" target="_blank" class="btn-down" style="padding:7px 11px;border-color:#00f3ff;color:#00f3ff;" title="Abrir en pantalla completa directa">&#8599;&#65039; Pantalla Completa</a>
                            <% } %>
                            <button type="button" class="btn-del" onclick="abrirConfirmarEliminar(<%= arc.getId() %>, '<%= safeTitulo %>', <%= s %>, <%= esAdmin %>)" title="Eliminar esta tarea">&#128465;&#65039; Eliminar</button>
                        </div>
                    </div>
                <% } } %>
            </div>

        </div>
    </div>
    <% } /* fin loop semanas */ %>

<% } /* fin tab archivos */ %>

<%-- ═══════════════════════════════════════════════════════
     TAB 03: CONTACTO
═══════════════════════════════════════════════════════ --%>
<% if ("contacto".equals(activeTab)) { %>

    <div class="contact-hub-grid">

        <%-- Carnet estudiantil --%>
        <div>
            <div class="student-id-card">
                <div class="id-header">
                    <div style="display:flex;align-items:center;gap:10px;">
                        <img src="<%= ctx %>/IMG/image.png" alt="UPLA"
                             style="height:38px;filter:drop-shadow(0 0 10px #ff007f);"
                             onerror="this.src='https://upload.wikimedia.org/wikipedia/commons/thumb/e/e0/Logo_Universidad_Peruana_Los_Andes.png/640px-Logo_Universidad_Peruana_Los_Andes.png'">
                        <div>
                            <div style="font-size:12.5px;font-weight:900;color:#fff;">UNIVERSIDAD PERUANA LOS ANDES</div>
                            <div style="font-size:10px;font-family:'Fira Code',monospace;color:#00f3ff;">FACULTAD DE INGENIERÍA &bull; EPISC</div>
                        </div>
                    </div>
                    <div class="id-chip"></div>
                </div>
                <div class="id-body">
                    <div class="id-photo">
                        <img src="<%= ctx %>/IMG/IMGS.jpeg" alt="Foto de <%= nombreAlumna %>"
                             style="width:100%;height:100%;object-fit:cover;"
                             onerror="this.style.display='none';this.parentNode.insertAdjacentHTML('beforeend','<span style=font-size:46px>&#127800;</span>');">
                        <div class="id-photo-badge">ESTUDIANTE</div>
                    </div>
                    <div class="id-details">
                        <div class="id-name"><%= nombreAlumna %></div>
                        <div class="id-spec">Ingeniería de Sistemas y Computación</div>
                        <div class="id-code">CORREO: <b style="color:#00f3ff;">s01269h@upla.edu.pe</b></div>
                        <div class="id-code" style="margin-top:4px;">ESTUDIANTE TITULAR &bull; 2026-I</div>
                    </div>
                </div>
                <div style="background:rgba(255,255,255,.035);border:1px solid rgba(216,132,255,.22);border-radius:12px;padding:12px;font-size:12px;line-height:1.5;color:#d8c6f2;">
                    &#128205; <b>Campus Chorrillos:</b> Av. Giráldez 230 / Av. Ferrocarril, Huancayo - Perú.<br>
                    &#127963; <b>Pabellón:</b> Facultad de Ingeniería &bull; EPISC.
                </div>
                <div class="digital-cert-seal">
                    <div style="font-family:'Fira Code',monospace;font-size:11.5px;font-weight:800;color:#00f3ff;">&#128737;&#65039; ACREDITACIÓN DIGITAL UNIVERSITARIA // EPISC UPLA</div>
                    <div style="font-family:'Fira Code',monospace;font-size:9.5px;color:#d884ff;margin-top:4px;">FIRMA CRIPTOGRÁFICA VERIFICADA &bull; HASH SHA-256: 332181-UPLA-2026</div>
                </div>
            </div>
        </div>

        <%-- Canales + form --%>
        <div>
            <div class="cyber-card">
                <span class="neon-sub">// COMUNICACIÓN DIRECTA &amp; CÁTEDRA</span>
                <h2 class="neon-title" style="font-size:22px;margin:6px 0 16px;">Canales Oficiales</h2>
                <div class="contact-links-grid">
                    <a href="mailto:s01269h@upla.edu.pe" class="social-card">
                        <div class="social-head"><div class="social-icon" style="color:#00f3ff;">&#9993;&#65039;</div><div><div class="social-title">Correo de la Autora</div><div class="social-tag">Buzón UPLA</div></div></div>
                        <div class="social-desc">Escríbeme directamente a <b>s01269h@upla.edu.pe</b> para consultas o revisiones.</div>
                        <div class="social-action">Abrir Correo &#10140;</div>
                    </a>
                    <a href="mailto:d.rfernandezb@ms.upla.edu.pe" class="social-card">
                        <div class="social-head"><div class="social-icon" style="color:#d884ff;">&#128104;&#8205;&#127979;</div><div><div class="social-title">Docente de Cátedra</div><div class="social-tag">Mg. Raúl Fernández</div></div></div>
                        <div class="social-desc">Correo de contacto del docente: <b>d.rfernandezb@ms.upla.edu.pe</b>.</div>
                        <div class="social-action">Contactar Docente &#10140;</div>
                    </a>
                    <a href="https://github.com" target="_blank" class="social-card">
                        <div class="social-head"><div class="social-icon">&#128025;</div><div><div class="social-title">GitHub Académico</div><div class="social-tag">Control de Versiones</div></div></div>
                        <div class="social-desc">Repositorio de código fuente en Java 17, Jakarta EE y MySQL.</div>
                        <div class="social-action">Ver Repositorio &#10140;</div>
                    </a>
                    <div class="social-card">
                        <div class="social-head"><div class="social-icon" style="color:#00ff88;">&#128205;</div><div><div class="social-title">Campus Universitario</div><div class="social-tag" style="color:#00ff88;">Huancayo, Junín</div></div></div>
                        <div class="social-desc">Facultad de Ingeniería &bull; Escuela Profesional de Ingeniería de Sistemas.</div>
                        <div class="social-action" style="color:#00ff88;">Sede Central UPLA</div>
                    </div>
                </div>
                <div style="margin-top:24px;padding-top:20px;border-top:1px dashed rgba(216,132,255,.25);">
                    <span class="neon-sub">// TRANSMISIÓN DIRECTA AL BUZÓN INSTITUCIONAL</span>
                    <form action="<%= ctx %>/contacto/enviar" method="POST" style="margin-top:12px;display:flex;gap:10px;">
                        <input type="text" name="mensaje" class="cyber-input" style="margin:0;"
                               placeholder="Escribe un mensaje institucional para Flor..." required>
                        <button type="submit" class="submit-btn" style="margin:0;width:auto;padding:0 24px;">ENVIAR</button>
                    </form>
                </div>
            </div>
        </div>
    </div>

<% } /* fin tab contacto */ %>

</main>

<%-- ═══════════════════════════════════════════════════════
     FLOR-CHAN — Asistente Anime Flotante
═══════════════════════════════════════════════════════ --%>
<div id="cyberCatContainer" onclick="toggleMichi()" title="🌸 ¡Haz clic para hablar con Flor-chan!">
    <div class="cat-bubble" id="animeBubbleText">🌸 ¡Konnichiwa Flor! ¿Subimos otra tarea hoy? ✨</div>
    <svg class="anime-mascot-sprite" viewBox="0 0 100 100" fill="none" xmlns="http://www.w3.org/2000/svg">
        <defs>
            <linearGradient id="hairGrad" x1="0%" y1="0%" x2="100%" y2="100%">
                <stop offset="0%" stop-color="#ff99cc"/>
                <stop offset="60%" stop-color="#ff3388"/>
                <stop offset="100%" stop-color="#aa0055"/>
            </linearGradient>
            <linearGradient id="ribbonGrad" x1="0%" y1="0%" x2="100%" y2="100%">
                <stop offset="0%" stop-color="#00f3ff"/>
                <stop offset="100%" stop-color="#0066ff"/>
            </linearGradient>
            <linearGradient id="skinGrad" x1="0%" y1="0%" x2="0%" y2="100%">
                <stop offset="0%" stop-color="#fff5f0"/>
                <stop offset="100%" stop-color="#ffe4dc"/>
            </linearGradient>
            <linearGradient id="eyeGrad" x1="0%" y1="0%" x2="0%" y2="100%">
                <stop offset="0%" stop-color="#ff007f"/>
                <stop offset="50%" stop-color="#990066"/>
                <stop offset="100%" stop-color="#110022"/>
            </linearGradient>
        </defs>

        <!-- Sparkles decorativos de fondo -->
        <circle cx="16" cy="18" r="2.5" fill="#00f3ff" style="animation: animeSparkleGlow 2s infinite ease-in-out;"/>
        <polygon points="85,20 87,25 92,27 87,29 85,34 83,29 78,27 83,25" fill="#ffdd55" style="animation: animeSparkleGlow 2.5s infinite ease-in-out 0.5s;"/>
        <polygon points="12,68 13.5,72 17,73.5 13.5,75 12,79 10.5,75 7,73.5 10.5,72" fill="#ff77aa" style="animation: animeSparkleGlow 1.8s infinite ease-in-out 0.8s;"/>

        <!-- Coletas Anime (Twintails) con animación de vaivén -->
        <g style="animation: animeHairSwayL 3s infinite ease-in-out; transform-origin: 28px 45px;">
            <path d="M 28 45 C 10 45 4 65 14 85 C 22 95 30 82 26 65 C 25 55 27 50 28 45 Z" fill="url(#hairGrad)" stroke="#880044" stroke-width="1.2"/>
            <ellipse cx="28" cy="45" rx="5" ry="4" fill="url(#ribbonGrad)"/>
            <circle cx="28" cy="45" r="2" fill="#fff"/>
        </g>
        <g style="animation: animeHairSwayR 3s infinite ease-in-out 0.3s; transform-origin: 72px 45px;">
            <path d="M 72 45 C 90 45 96 65 86 85 C 78 95 70 82 74 65 C 75 55 73 50 72 45 Z" fill="url(#hairGrad)" stroke="#880044" stroke-width="1.2"/>
            <ellipse cx="72" cy="45" rx="5" ry="4" fill="url(#ribbonGrad)"/>
            <circle cx="72" cy="45" r="2" fill="#fff"/>
        </g>

        <!-- Cabello posterior -->
        <path d="M 24 45 C 24 20 76 20 76 45 C 76 60 70 70 50 70 C 30 70 24 60 24 45 Z" fill="url(#hairGrad)"/>

        <!-- Cuello y uniforme escolar marinero / blusa -->
        <path d="M 44 65 L 56 65 L 58 72 L 42 72 Z" fill="url(#skinGrad)"/>
        <!-- Torso con uniforme -->
        <path d="M 36 72 C 36 72 42 70 50 70 C 58 70 64 72 64 72 L 67 92 C 67 92 56 94 50 94 C 44 94 33 92 33 92 Z" fill="#1e1035" stroke="#ff007f" stroke-width="1.2"/>
        <!-- Cuello marinero blanco y corbatín rosa -->
        <polygon points="40,71 50,83 45,84 38,74" fill="#ffffff"/>
        <polygon points="60,71 50,83 55,84 62,74" fill="#ffffff"/>
        <ellipse cx="50" cy="80" rx="3.5" ry="3.5" fill="#ff007f"/>
        <path d="M 48 83 L 44 92 L 49 90 L 50 83" fill="#ff007f"/>
        <path d="M 52 83 L 56 92 L 51 90 L 50 83" fill="#ff007f"/>

        <!-- Rostro anime (Chibi head) -->
        <path d="M 30 46 C 30 30 70 30 70 46 C 70 60 63 68 50 68 C 37 68 30 60 30 46 Z" fill="url(#skinGrad)" stroke="#e8b0a0" stroke-width="1"/>

        <!-- Sonrojo anime en mejillas (Blush) -->
        <ellipse cx="37" cy="55" rx="4.5" ry="2.2" fill="#ff66b2" opacity="0.6"/>
        <line x1="34" y1="55" x2="36" y2="54" stroke="#ff3388" stroke-width="1"/>
        <line x1="37" y1="56" x2="39" y2="55" stroke="#ff3388" stroke-width="1"/>
        <ellipse cx="63" cy="55" rx="4.5" ry="2.2" fill="#ff66b2" opacity="0.6"/>
        <line x1="61" y1="55" x2="63" y2="54" stroke="#ff3388" stroke-width="1"/>
        <line x1="64" y1="56" x2="66" y2="55" stroke="#ff3388" stroke-width="1"/>

        <!-- Ojos Anime Grandes y Expresivos (con animación de parpadeo) -->
        <g style="animation: animeEyeBlink 4.2s infinite ease-in-out; transform-origin: 50px 48px;">
            <!-- Ojo izquierdo -->
            <ellipse cx="40" cy="49" rx="5.5" ry="7.5" fill="url(#eyeGrad)"/>
            <path d="M 34 43 Q 40 40 46 43" stroke="#220033" stroke-width="2.2" stroke-linecap="round"/>
            <circle cx="38" cy="46" r="2.2" fill="#ffffff"/>
            <circle cx="42" cy="52" r="1.1" fill="#ffffff"/>
            <polygon points="40,50 41,51.5 42,50 41,48.5" fill="#00f3ff"/>

            <!-- Ojo derecho -->
            <ellipse cx="60" cy="49" rx="5.5" ry="7.5" fill="url(#eyeGrad)"/>
            <path d="M 54 43 Q 60 40 66 43" stroke="#220033" stroke-width="2.2" stroke-linecap="round"/>
            <circle cx="58" cy="46" r="2.2" fill="#ffffff"/>
            <circle cx="62" cy="52" r="1.1" fill="#ffffff"/>
            <polygon points="60,50 61,51.5 62,50 61,48.5" fill="#00f3ff"/>
        </g>

        <!-- Nariz y Boquita Anime Feliz -->
        <path d="M 48.5 54 L 49.5 55" stroke="#d48877" stroke-width="0.8" stroke-linecap="round"/>
        <path d="M 47 59 Q 50 62 53 59" stroke="#990033" stroke-width="1.8" stroke-linecap="round" fill="#ff5588"/>

        <!-- Flequillo y Mechones Anime Frontales -->
        <path d="M 28 42 C 32 30 68 30 72 42 C 70 42 66 38 60 44 C 56 41 52 41 50 45 C 48 40 42 40 38 45 C 34 39 30 42 28 42 Z" fill="url(#hairGrad)"/>
        <!-- Reflejo de luz en el cabello anime -->
        <path d="M 36 34 Q 50 30 64 34" stroke="#ffffff" stroke-width="1.8" stroke-linecap="round" opacity="0.65"/>

        <!-- Manitas saludando (Cute paws/hands) -->
        <ellipse cx="32" cy="78" rx="3.5" ry="3" fill="url(#skinGrad)" stroke="#e8b0a0" stroke-width="0.8"/>
        <ellipse cx="68" cy="78" rx="3.5" ry="3" fill="url(#skinGrad)" stroke="#e8b0a0" stroke-width="0.8"/>
    </svg>
</div>

<div id="michiWindow">
    <div class="michi-head">
        <div class="michi-title">🌸 FLOR-CHAN // ASISTENTE ANIME DEL PORTAFOLIO</div>
        <button onclick="toggleMichi()" style="background:transparent;border:none;color:#ff6688;font-size:16px;cursor:pointer;font-weight:900;">&#10005;</button>
    </div>
    <div class="michi-body" id="michiMessages">
        <div class="michi-msg msg-bot">🌸 ¡Konnichiwa <%= esAdmin ? nombreAlumna : "visitante" %>! Soy <b>Flor-chan</b>, tu asistente anime del portafolio.<br><br>
        Sé <b>TODO</b> sobre este portafolio: el docente Mg. Raúl Fernández, las 16 semanas, el sílabo y más. ¿Qué deseas consultar?</div>
    </div>
    <div class="michi-chips">
        <div class="m-chip" onclick="askMichi('¿Quién es el docente?')">&#128104;&#8205;&#127979; El Ingeniero Docente</div>
        <div class="m-chip" onclick="askMichi('¿Quién es la autora?')">&#127800; Alumna Titular</div>
        <div class="m-chip" onclick="askMichi('¿Qué vemos en Semana 4?')">&#128208; Semana 4 (Vistas 4+1)</div>
        <div class="m-chip" onclick="askMichi('¿Qué es la sumilla del curso?')">&#128214; Sumilla del Sílabo</div>
    </div>
    <div class="michi-input-box">
        <input type="text" id="michiInput" class="michi-input"
               placeholder="Escribe cualquier pregunta para Michi..."
               onkeydown="if(event.key==='Enter') sendMichi();">
        <button class="michi-send-btn" onclick="sendMichi()">ENVIAR</button>
    </div>
</div>

<%-- ═══ MODAL VISOR PDF Y DOCUMENTOS MEJORADO ═════════════ --%>
<div id="pdfModal" class="cyber-modal" style="display:none;">
    <div class="modal-dialog" style="max-width:1150px; width:95%; height:90vh; display:flex; flex-direction:column; padding:22px; border: 1.5px solid #00f3ff; box-shadow: 0 0 50px rgba(0,243,255,0.4);">
        <div class="modal-header" style="margin-bottom:12px; padding-bottom:12px; display:flex; justify-content:space-between; align-items:center; flex-wrap:wrap; gap:10px;">
            <div style="display:flex; align-items:center; gap:10px;">
                <span style="font-size:22px;">&#128196;</span>
                <div>
                    <div class="modal-title" id="pdfTitle" style="color:#00f3ff; font-size:15px; font-weight:800; max-width:550px; white-space:nowrap; overflow:hidden; text-overflow:ellipsis;">DOCUMENTO ACADÉMICO</div>
                    <div style="font-family:'Fira Code',monospace; font-size:10px; color:#d884ff;">VISOR DE ALTA RESOLUCIÓN // ARQUITECTURA DE SOFTWARE</div>
                </div>
            </div>
            <div style="display:flex; gap:10px; align-items:center; flex-wrap:wrap;">
                <a id="modalFullscreenBtn" href="#" target="_blank" class="btn-down" style="border-color:#00f3ff; color:#00f3ff; padding:8px 14px; font-size:11px;" title="Abrir en pestaña nueva">
                    &#8599;&#65039; PANTALLA COMPLETA
                </a>
                <a id="modalDownloadBtn" href="#" target="_blank" class="btn-down" style="padding:8px 14px; font-size:11px;" title="Descargar fichero">
                    &#128229; DESCARGAR
                </a>
                <button type="button" class="modal-close" onclick="closeDocModal()">
                    &#10005; CERRAR [ESC]
                </button>
            </div>
        </div>
        <div style="flex:1; position:relative; background:#070210; border-radius:14px; overflow:hidden; border:1px solid rgba(216,132,255,0.3); display:flex; flex-direction:column;">
            <iframe id="pdfFrame" src="" style="flex:1; width:100%; height:100%; border:none; background:#ffffff;"></iframe>
        </div>
        <div style="margin-top:10px; display:flex; justify-content:space-between; align-items:center; font-family:'Fira Code',monospace; font-size:11px; color:#cba6f7; flex-wrap:wrap; gap:8px;">
            <span>&#128161; Si tu navegador restringe la visualización interna, presiona <b>PANTALLA COMPLETA</b>.</span>
            <span style="color:#00f3ff;">UNIVERSIDAD PERUANA LOS ANDES &bull; 2026</span>
        </div>
    </div>
</div>

<%-- ═══ MODAL ELIMINAR ARCHIVO (ELEGANTE Y EN SERIO) ═════ --%>
<div id="deleteConfirmModal" class="cyber-modal" style="display:none;">
    <div class="modal-dialog" style="max-width:520px; border: 1.8px solid #ff0055; box-shadow: 0 0 60px rgba(255,0,85,0.45); animation: fadeInWeek .3s ease;">
        <div class="modal-header" style="border-color:rgba(255,0,85,0.3);">
            <div class="modal-title" style="color:#ff4d6d; display:flex; align-items:center; gap:8px;">
                <span style="font-size:18px;">&#9888;&#65039;</span> CONFIRMAR ELIMINACIÓN PERMANENTE
            </div>
            <button type="button" class="modal-close" onclick="cerrarConfirmarEliminar()">&times;</button>
        </div>
        <div style="padding:10px 0 10px;">
            <div style="text-align:center; margin-bottom:16px;">
                <div style="width:68px; height:68px; border-radius:50%; background:rgba(255,0,85,0.15); border:2px solid #ff0055; display:inline-flex; align-items:center; justify-content:center; font-size:32px; box-shadow:0 0 25px rgba(255,0,85,0.5);">
                    &#128465;&#65039;
                </div>
            </div>
            <div id="delDocTitleDisplay" style="font-size:15px; font-weight:900; color:#fff; text-align:center; margin-bottom:8px; line-height:1.4;">
                Título del archivo
            </div>
            <p style="font-size:12px; color:#e0c3fc; text-align:center; line-height:1.6; margin-bottom:16px;">
                ¿Estás seguro de que deseas eliminar este documento? Esta acción eliminará <b>definitivamente</b> el registro en MySQL y el archivo físico del servidor.
            </p>

            <div id="delAuthBox" style="<%= esAdmin ? "display:none;" : "display:block;" %> background:rgba(255,255,255,0.03); border:1px solid rgba(216,132,255,0.25); border-radius:14px; padding:14px; margin-bottom:16px;">
                <label style="font-size:11px; font-family:'Fira Code',monospace; color:#00f3ff; display:block; margin-bottom:6px; font-weight:700;">
                    &#128273; CLAVE DE CONFIRMACIÓN DE ALUMNA TITULAR:
                </label>
                <div style="position:relative; display:flex; align-items:center;">
                    <input type="password" id="delTokenInput" class="cyber-input" value="" placeholder="Escribe tu clave de confirmación..." autocomplete="off" style="color:#00f3ff; font-weight:700; letter-spacing:1px; width:100%; padding-right:85px;">
                    <button type="button" onclick="togglePasswordVisibility('delTokenInput', 'delPassEyeIcon', 'delPassEyeLabel')" style="position:absolute; right:8px; top:50%; transform:translateY(-50%); background:rgba(255,255,255,0.08); border:1px solid rgba(0,243,255,0.3); color:#00f3ff; border-radius:8px; padding:5px 9px; font-size:10.5px; font-family:'Fira Code',monospace; font-weight:800; cursor:pointer; display:flex; align-items:center; gap:4px;">
                        <i class="fas fa-eye" id="delPassEyeIcon"></i>
                        <span id="delPassEyeLabel">VER</span>
                    </button>
                </div>
                <div style="font-size:10px; color:#d884ff; font-family:'Fira Code',monospace; margin-top:6px;">
                    🔒 Acción protegida &bull; Ingresa tu clave para autorizar el borrado.
                </div>
            </div>

            <div style="display:flex; gap:12px;">
                <button type="button" class="btn-exit" onclick="cerrarConfirmarEliminar()" style="flex:1; padding:12px; font-size:12px; text-align:center; cursor:pointer; background:rgba(255,255,255,0.06); border-color:rgba(255,255,255,0.2); color:#cbd5e1;">
                    CANCELAR
                </button>
                <button type="button" id="btnConfirmarDel" onclick="confirmarBorradoDefinitivo()" class="submit-btn" style="flex:1.5; margin:0; padding:12px 16px; font-size:12px; background:linear-gradient(135deg,#ff0055 0%,#b3003b 100%); box-shadow:0 0 25px rgba(255,0,85,0.6);">
                    &#128465;&#65039; SÍ, ELIMINAR EN SERIO
                </button>
            </div>
        </div>
    </div>
</div>

<%-- ═══ TOAST NOTIFICACIÓN CIBERNÉTICA ════════════════════ --%>
<div id="cyberToast" style="position:fixed; bottom:25px; left:50%; transform:translateX(-50%); background:rgba(20,7,40,0.96); border:1.5px solid #00f3ff; border-radius:16px; padding:12px 24px; color:#fff; font-family:'Fira Code',monospace; font-size:12px; font-weight:800; box-shadow:0 0 35px rgba(0,243,255,0.5); z-index:999999; display:none; align-items:center; gap:10px; transition:opacity .3s ease;">
    <span id="toastIcon">&#10024;</span>
    <span id="toastMsg">Mensaje del sistema</span>
</div>

<%-- ═══ MODAL EDITAR NOMBRE (solo admin) ═════════════════ --%>
<% if (esAdmin) { %>
<div id="editModal" class="cyber-modal" style="display:none;">
    <div class="modal-dialog" style="max-width:500px;">
        <div class="modal-header">
            <div class="modal-title">&#9999;&#65039; EDITAR NOMBRE DE LA ALUMNA TITULAR</div>
            <button class="modal-close" onclick="document.getElementById('editModal').style.display='none';">&#10005;</button>
        </div>
        <form action="<%= ctx %>/perfil/actualizar" method="POST">
            <label style="font-size:11.5px;font-family:'Fira Code',monospace;color:#d884ff;display:block;margin-bottom:6px;font-weight:700;">NOMBRE COMPLETO:</label>
            <input type="text" name="nombre" class="cyber-input" value="<%= nombreAlumna %>" required>
            <button type="submit" class="submit-btn" style="margin-top:14px;">GUARDAR CAMBIOS</button>
        </form>
    </div>
</div>
<% } %>

<%-- ═══ MODAL ACCESO PRIVADO DE ALUMNA (MODIFICAR & SUBIR) ═════════════════ --%>
<% if (!esAdmin) { %>
<div id="alumnaModal" class="cyber-modal" style="display:none;" onclick="if(event.target === this) closeAlumnaModal();">
    <div class="modal-dialog alumna-dialog" style="max-width:490px; border:2px solid var(--border-accent); border-radius:28px; padding:32px 28px; box-shadow:0 0 65px rgba(255,0,127,0.5), 0 20px 60px rgba(0,0,0,0.85); background:var(--bg-surface-solid); animation:fadeInWeek .3s ease; position:relative; overflow:hidden;">
        <!-- Resplandor decorativo anime -->
        <div style="position:absolute; top:-50px; right:-50px; width:150px; height:150px; background:radial-gradient(circle, var(--accent-pink), transparent 70%); filter:blur(30px); pointer-events:none; opacity:0.4;"></div>
        <div style="position:absolute; bottom:-50px; left:-50px; width:150px; height:150px; background:radial-gradient(circle, var(--accent-cyan), transparent 70%); filter:blur(30px); pointer-events:none; opacity:0.35;"></div>

        <div class="modal-header" style="border-bottom:1.5px solid var(--border-color); padding-bottom:14px; margin-bottom:20px; display:flex; justify-content:space-between; align-items:center;">
            <div class="modal-title" style="color:var(--text-primary); font-size:15px; font-weight:900; display:flex; align-items:center; gap:8px;">
                <span style="font-size:22px; filter:drop-shadow(0 0 10px var(--accent-pink));">🌸</span>
                <span>PORTAL PRIVADO &bull; FLOR XIOMARA</span>
            </div>
            <button type="button" class="modal-close" onclick="closeAlumnaModal()" style="background:rgba(255,0,80,0.18); border:1.5px solid #ff0055; color:#ff6688; border-radius:10px; width:34px; height:34px; font-size:16px; font-weight:900; cursor:pointer; display:flex; align-items:center; justify-content:center; transition:.2s;" title="Cerrar">&times;</button>
        </div>

        <!-- Tarjeta de Flor Xiomara con Avatar e Información -->
        <div style="background:linear-gradient(135deg, rgba(255,255,255,0.04) 0%, rgba(255,0,127,0.08) 100%); border:1.5px solid var(--border-color); border-radius:18px; padding:16px; margin-bottom:18px; display:flex; align-items:center; gap:15px; box-shadow:0 8px 25px rgba(0,0,0,0.3);">
            <div style="width:56px; height:56px; border-radius:18px; border:2px solid var(--accent-pink); background:radial-gradient(circle, #ff007f 0%, #3b0764 100%); display:flex; align-items:center; justify-content:center; font-size:26px; box-shadow:0 0 20px rgba(255,0,127,0.6); flex-shrink:0;">
                👩‍🎓
            </div>
            <div style="flex:1;">
                <div style="font-size:14.5px; font-weight:900; color:#fff; text-shadow:0 0 10px rgba(255,255,255,0.3);">Flor Xiomara Medina Salazar</div>
                <div style="font-size:11px; color:var(--accent-cyan); font-family:'Fira Code',monospace; font-weight:700; margin-top:2px;">
                    ✨ Alumna Titular &bull; EPISC UPLA &bull; Cel: 949163067
                </div>
                <div style="font-size:10px; color:var(--text-secondary); margin-top:2px;">
                    Arquitectura de Software 2026-I
                </div>
            </div>
        </div>

        <p style="font-size:12px; color:var(--text-secondary); line-height:1.55; margin-bottom:18px; font-family:'Plus Jakarta Sans',sans-serif;">
            Escribe tu contraseña o código de acceso para desbloquear el <b>Modo Edición</b>, subir ("alsar") tareas en las 16 semanas y gestionar tus documentos.
        </p>

        <!-- FORMULARIO DE ACCESO: CAMPO VACÍO PARA ESCRIBIR Y BOTÓN VER/OCULTAR CONTRASEÑA -->
        <form action="<%= ctx %>/login" method="POST" id="modalLoginForm">
            <label for="modalCodigoInput" style="font-size:11px; font-family:'Fira Code',monospace; color:var(--accent-cyan); display:flex; justify-content:space-between; margin-bottom:8px; font-weight:800;">
                <span>🔐 CONTRASEÑA O CÓDIGO:</span>
                <span style="color:var(--text-muted); font-size:10px; font-weight:400;">(Escribe tu clave)</span>
            </label>

            <!-- INPUT GROUP CON BOTÓN VER/NO VER AL COSTADO -->
            <div style="position:relative; display:flex; align-items:center; margin-bottom:10px;">
                <span style="position:absolute; left:16px; color:var(--accent-cyan); font-family:'Fira Code',monospace; font-size:14px; pointer-events:none; font-weight:900;">&gt;_</span>
                
                <input type="password" 
                       name="codigo" 
                       id="modalCodigoInput" 
                       class="cyber-input" 
                       value="" 
                       placeholder="Escribe tu contraseña o código aquí..." 
                       required 
                       autofocus 
                       autocomplete="current-password"
                       style="width:100%; padding:14px 105px 14px 44px; font-family:'Fira Code',monospace; font-size:13.5px; font-weight:700; color:#fff; background:rgba(18,6,36,0.9); border:1.8px solid var(--border-color); border-radius:14px; outline:none; transition:all 0.3s ease;">

                <!-- BOTÓN VER / NO VER CONTRASEÑA AL COSTADO -->
                <button type="button" 
                        id="modalTogglePassBtn"
                        onclick="togglePasswordVisibility('modalCodigoInput', 'modalPassEyeIcon', 'modalPassEyeLabel')"
                        style="position:absolute; right:8px; top:50%; transform:translateY(-50%); background:rgba(255,255,255,0.08); border:1px solid var(--border-color); color:var(--accent-cyan); border-radius:10px; padding:6px 10px; font-size:11px; font-family:'Fira Code',monospace; font-weight:800; cursor:pointer; display:flex; align-items:center; gap:5px; transition:all 0.2s ease;"
                        title="Ver u ocultar contraseña">
                    <i class="fas fa-eye" id="modalPassEyeIcon"></i>
                    <span id="modalPassEyeLabel">VER</span>
                </button>
            </div>

            <div style="font-size:10.5px; color:var(--text-secondary); margin-bottom:20px; font-family:'Fira Code',monospace; padding:7px 12px; background:rgba(255,255,255,0.03); border-radius:10px; border-left:3px solid var(--accent-cyan);">
                🔒 <b>Acceso Protegido</b> &bull; Escribe tu clave personal autorizada para ingresar.
            </div>

            <button type="submit" class="submit-btn" style="background:var(--accent-gradient); padding:15px; font-size:13px; font-weight:900; letter-spacing:1px; border-radius:14px; box-shadow:0 0 30px rgba(255,0,127,0.55); margin-top:4px; display:flex; align-items:center; justify-content:center; gap:10px; cursor:pointer;">
                <i class="fas fa-unlock-alt"></i> 🔓 INGRESAR AL PORTAFOLIO
            </button>
        </form>
    </div>
</div>
<% } %>

<%-- ═══════════════════════════════════════════════════════
     JAVASCRIPT
═══════════════════════════════════════════════════════ --%>
<script>
/* ═══════════════════════════════════════════════════════
   SISTEMA DE TEMAS VISUALES DINÁMICOS & ANIME INNOVADOR
═══════════════════════════════════════════════════════ */
/* ═══════════════════════════════════════════════════════
   UTILIDADES & VER / OCULTAR CONTRASEÑA
═══════════════════════════════════════════════════════ */
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

/* ═══════════════════════════════════════════════════════
   SISTEMA DE TEMAS VISUALES DINÁMICOS & ANIME INNOVADOR
═══════════════════════════════════════════════════════ */
let currentThemeMode = 'sakura';
let themeParticlePalette = ['#ff77aa', '#ff1493', '#ff85c0', '#ffd6eb'];
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

function setTheme(theme, showNotification) {
    theme = normalizeTheme(theme);
    currentThemeMode = theme;
    document.documentElement.setAttribute('data-theme', theme);
    localStorage.setItem('portfolio_theme', theme);

    // Actualizar botones en el dropdown
    document.querySelectorAll('.theme-opt-btn').forEach(btn => {
        const val = normalizeTheme(btn.getAttribute('data-theme-val'));
        if (val === theme) {
            btn.classList.add('active');
        } else {
            btn.classList.remove('active');
        }
    });

    // Actualizar paleta del fondo canvas y regenerar partículas del tema
    actualizarColoresCanvas(theme);

    // Sonido dulce de campana anime al cambiar tema
    if (showNotification !== false) {
        playAnimeChime(659.25, 880.00); // E5 -> A5
    }

    // Cerrar menú dropdown si estaba abierto
    const menu = document.getElementById('themeDropdownMenu');
    if (menu) menu.classList.remove('show');

    // Notificación toast
    if (showNotification !== false && typeof mostrarToast === 'function') {
        const nombres = {
            'sakura': '🌸 Anime Sakura (Cardcaptor & Pétalos 3D)',
            'ghibli': '🌌 Kimi no Na wa (Your Name Crepúsculo & Cometa)',
            'kimetsu': '⚔️ Kimetsu no Yaiba (Demon Slayer Fuego & Katana)',
            'lofi': '☕ Ghibli Cafe (Studio Ghibli & Atardecer Chillhop)',
            'cyber': '⚡ Cyberpunk 2077 (Neo Tokyo Edgerunners)',
            'zen': '✨ Minimal Zen (Blanco Cristalino de Lujo)'
        };
        mostrarToast('🎨 Tema activado: ' + (nombres[theme] || theme), 'ok');
    }
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

/* ═══════════════════════════════════════════════════════
   MOTOR DE AUDIO ESTUDIO ANIME & LO-FI REAL
═══════════════════════════════════════════════════════ */
const ANIME_TRACKS = [
    {
        id: 'sakura',
        name: '🌸 01. Sakura Chill',
        title: 'Sakura Anime Chill Beats (Piano & Koto)',
        src: '<%= ctx %>/sakura_lofi.mp3'
    },
    {
        id: 'ghibli',
        name: '☕ 02. Ghibli Study',
        title: 'Ghibli Study Lofi Beats (Relax & Focus)',
        src: '<%= ctx %>/anime_lofi.mp3'
    }
];

let currentTrackIdx = 0;
let isMusicPlaying = false;
let bgAudio = null;

function initMusicEngine() {
    bgAudio = document.getElementById('bgMusicPlayer');
    const savedTrack = localStorage.getItem('portfolio_music_track');
    if (savedTrack !== null) {
        const idx = parseInt(savedTrack, 10);
        if (idx >= 0 && idx < ANIME_TRACKS.length) currentTrackIdx = idx;
    }

    const savedVol = localStorage.getItem('portfolio_music_vol');
    const vol = (savedVol !== null) ? parseFloat(savedVol) : 0.65;
    const slider = document.getElementById('musicVolumeSlider');
    if (slider) slider.value = vol;

    if (bgAudio) {
        bgAudio.src = ANIME_TRACKS[currentTrackIdx].src;
        bgAudio.volume = vol;
        bgAudio.onended = () => nextTrack();
        bgAudio.onplay  = () => updateMusicUI(true);
        bgAudio.onpause = () => updateMusicUI(false);
    }
    updateTrackLabel();
}

function updateTrackLabel() {
    const track = ANIME_TRACKS[currentTrackIdx];
    const lbl = document.getElementById('trackNameLabel');
    if (lbl && track) lbl.innerText = track.name;
}

function nextTrack(e) {
    if (e) e.stopPropagation();
    currentTrackIdx = (currentTrackIdx + 1) % ANIME_TRACKS.length;
    localStorage.setItem('portfolio_music_track', currentTrackIdx);
    updateTrackLabel();
    const track = ANIME_TRACKS[currentTrackIdx];
    if (bgAudio) {
        bgAudio.src = track.src;
        if (isMusicPlaying) {
            bgAudio.play().catch(() => {});
        }
    }
    if (typeof mostrarToast === 'function') {
        mostrarToast('🎵 Sonando: ' + track.title, 'ok');
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
        pauseMusic();
        localStorage.setItem('portfolio_music_enabled', 'false');
    } else {
        playMusic();
        localStorage.setItem('portfolio_music_enabled', 'true');
    }
}

function playMusic() {
    if (!bgAudio) initMusicEngine();
    if (!bgAudio.src || bgAudio.src === '' || bgAudio.src.indexOf('.mp3') === -1) {
        bgAudio.src = ANIME_TRACKS[currentTrackIdx].src;
    }
    const playPromise = bgAudio.play();
    if (playPromise !== undefined) {
        playPromise.then(() => {
            isMusicPlaying = true;
            updateMusicUI(true);
            const track = ANIME_TRACKS[currentTrackIdx];
            if (typeof mostrarToast === 'function') {
                mostrarToast('🎵 Sonando: ' + track.title, 'ok');
            }
        }).catch(err => {
            console.log('Audio playback interaction needed:', err);
            updateMusicUI(false);
            if (typeof mostrarToast === 'function') {
                mostrarToast('🎵 Haz clic en el botón MÚSICA para activar el sonido anime', 'info');
            }
        });
    }
}

function pauseMusic() {
    if (bgAudio) bgAudio.pause();
    isMusicPlaying = false;
    updateMusicUI(false);
}

function setMusicVolume(val) {
    const v = Math.max(0, Math.min(1, parseFloat(val)));
    localStorage.setItem('portfolio_music_vol', v);
    if (bgAudio) bgAudio.volume = v;
}

function playAnimeChime(f1, f2) {}
function playSynthAnimeTrack() {}
function stopSynthEngine() {}

// Iniciar música si el usuario la tenía activada previamente con clic
window.addEventListener('click', () => {
    const shouldPlay = localStorage.getItem('portfolio_music_enabled');
    if (shouldPlay === 'true' && !isMusicPlaying) {
        playMusic();
    }
}, { once: true });

function openAlumnaModal(e) {
    if (e) e.preventDefault();
    const m = document.getElementById('alumnaModal');
    if (m) {
        m.style.display = 'flex';
        const inp = document.getElementById('modalCodigoInput');
        if (inp) { inp.focus(); inp.select(); }
    } else {
        window.location.href = '<%= ctx %>/login';
    }
}

function closeAlumnaModal() {
    const m = document.getElementById('alumnaModal');
    if (m) m.style.display = 'none';
}

/* ── CARRUSEL DE SEMANAS ──────────────────────────────── */
let curWeek = <%= initialSemana %>;

function selectWeek(n) {
    curWeek = n;
    document.querySelectorAll('.week-card').forEach(el => el.classList.remove('active-week'));
    document.querySelectorAll('.week-pill').forEach(el => el.classList.remove('active-pill'));
    const card = document.getElementById('week-card-' + n);
    const pill = document.getElementById('pill-' + n);
    if (card) card.classList.add('active-week');
    if (pill) {
        pill.classList.add('active-pill');
        pill.scrollIntoView({ behavior: 'smooth', inline: 'center', block: 'nearest' });
    }
    const st = document.getElementById('carouselStatus');
    if (st) st.innerText = 'NAVEGANDO SEMANA ' + (n < 10 ? '0' + n : n) + ' DE 16';
    const inp = document.getElementById('formSemanaInput');
    if (inp) inp.value = n;

    // Mantener la semana activa en la URL sin recargar la página
    try {
        const u = new URL(window.location);
        u.searchParams.set('semana', n);
        window.history.replaceState({}, '', u);
    } catch(e) {}
}

function changeWeek(d) {
    let next = curWeek + d;
    if (next < 1)  next = 16;
    if (next > 16) next = 1;
    selectWeek(next);
}

/* ── FLOR-CHAN ANIME ASISTENTE ── */
const ANIME_MASCOT_PHRASES = [
    '🌸 ¡Konnichiwa Flor! ¿Subimos otra tarea hoy? ✨',
    '🌸 ¡Ganbatte! ¡Vamos por ese 20 en Arquitectura! 📚',
    '🌸 ¡Tócame para consultarme sobre el curso o las 16 semanas! 💬',
    '🌸 ¡Música anime lo-fi activada para estudiar! 🎧',
    '🌸 ¿Quieres cambiar de tema anime arriba? 🎨'
];
let animePhraseIdx = 0;
setInterval(() => {
    const bubble = document.getElementById('animeBubbleText');
    if (bubble) {
        animePhraseIdx = (animePhraseIdx + 1) % ANIME_MASCOT_PHRASES.length;
        bubble.innerText = ANIME_MASCOT_PHRASES[animePhraseIdx];
    }
}, 6500);

function toggleMichi() {
    const w = document.getElementById('michiWindow');
    w.style.display = (w.style.display === 'flex') ? 'none' : 'flex';
    if (w.style.display === 'flex') document.getElementById('michiInput').focus();
}

function askMichi(q) {
    document.getElementById('michiInput').value = q;
    sendMichi();
}

function sendMichi() {
    const input = document.getElementById('michiInput');
    const text  = input.value.trim();
    if (!text) return;
    const box = document.getElementById('michiMessages');
    box.innerHTML += `<div class="michi-msg msg-user">${text}</div>`;
    input.value = '';
    box.scrollTop = box.scrollHeight;
    setTimeout(() => {
        let resp = '🌸 (◕‿◕) ¡Konnichiwa! No tengo esa consulta exacta, pero puedes revisar las 16 semanas en el carrusel o consultar el correo de Flor.';
        const t = text.toLowerCase();
        if (t.includes('docente') || t.includes('profesor') || t.includes('raul') || t.includes('raúl')) {
            resp = '👨‍🏫 El docente titular es el <b>Mg. Raúl Enrique Fernández Bejarano</b>. Su correo oficial es <b>d.rfernandezb@ms.upla.edu.pe</b> y el semestre va del 06 de Abril al 26 de Julio de 2026.';
        } else if (t.includes('autora') || t.includes('flor') || t.includes('estudiante') || t.includes('alumna')) {
            resp = '🌸 La autora titular es <b>Flor Xiomara Medina Salazar</b>, estudiante de Ingeniería de Sistemas y Computación (EPISC - UPLA). Correo: <b>s01269h@upla.edu.pe</b>.';
        } else if (t.includes('sumilla') || t.includes('silabo') || t.includes('sílabo') || t.includes('competencia')) {
            resp = '📖 <b>Sumilla:</b> Asignatura práctica orientada a formular soluciones arquitectónicas bajo normas IEEE 1471 e ISO/IEC 25010, POO, modelos 4+1 vistas de Kruchten y Jakarta EE.';
        } else if (t.includes('semana 4') || t.includes('4+1') || t.includes('kruchten')) {
            resp = '📐 <b>Semana 04:</b> Modelo de 4+1 Vistas de Philippe Kruchten (Lógica, Desarrollo, Procesos, Física y Casos de Uso) con diagramas de despliegue.';
        } else if (t.includes('correo') || t.includes('email')) {
            resp = '📧 Correo de Flor Xiomara: <b>s01269h@upla.edu.pe</b> | Docente: <b>d.rfernandezb@ms.upla.edu.pe</b>.';
        } else if (t.includes('upla') || t.includes('universidad')) {
            resp = '🏛️ <b>Universidad Peruana Los Andes (UPLA)</b>, Facultad de Ingeniería, Escuela Profesional de Ingeniería de Sistemas y Computación (EPISC). Campus Chorrillos, Huancayo, Perú.';
        }
        box.innerHTML += `<div class="michi-msg msg-bot">${resp}</div>`;
        box.scrollTop = box.scrollHeight;
    }, 380);
}

/* ── NOTIFICACIONES TOAST CIBERNÉTICAS ────────────────── */
function mostrarToast(msg, tipo) {
    const t = document.getElementById('cyberToast');
    const m = document.getElementById('toastMsg');
    const icon = document.getElementById('toastIcon');
    if (!t || !m) return;
    m.innerText = msg;
    if (tipo === 'del') {
        t.style.borderColor = '#ff0055';
        t.style.boxShadow = '0 0 35px rgba(255,0,85,0.6)';
        if (icon) icon.innerText = '🗑️';
    } else {
        t.style.borderColor = '#00f3ff';
        t.style.boxShadow = '0 0 35px rgba(0,243,255,0.6)';
        if (icon) icon.innerText = '✨';
    }
    t.style.display = 'flex';
    t.style.opacity = '1';
    setTimeout(() => {
        t.style.opacity = '0';
        setTimeout(() => { t.style.display = 'none'; }, 300);
    }, 3500);
}

/* ── MODAL VISOR DOCUMENTO (PDF / WORD / DOC) ────────── */
function openDocModal(urlVer, title, type, urlDown) {
    const titleEl = document.getElementById('pdfTitle');
    if (titleEl) titleEl.innerText = (title || 'DOCUMENTO').toUpperCase();

    // Configurar enlaces de acción rápida
    const fsBtn = document.getElementById('modalFullscreenBtn');
    if (fsBtn) fsBtn.href = urlVer;

    const downBtn = document.getElementById('modalDownloadBtn');
    if (downBtn) downBtn.href = urlDown || urlVer;

    let targetUrl = urlVer;
    if (type === 'word') {
        const fullUrl = urlVer.startsWith('http') ? urlVer : (window.location.origin + urlVer);
        targetUrl = 'https://view.officeapps.live.com/op/embed.aspx?src=' + encodeURIComponent(fullUrl);
    }

    const frame = document.getElementById('pdfFrame');
    if (frame) frame.src = targetUrl;

    const modal = document.getElementById('pdfModal');
    if (modal) modal.style.display = 'flex';
}

function closeDocModal() {
    const modal = document.getElementById('pdfModal');
    if (modal) modal.style.display = 'none';
    const frame = document.getElementById('pdfFrame');
    if (frame) frame.src = '';
}

function openPdfModal(url, title) {
    openDocModal(url, title, 'pdf', url);
}

/* ── ELIMINACIÓN DE ARCHIVO (ELEGANTE CON MODAL Y AJAX) ── */
let archivoAEliminar = { id: null, semana: 1, esAdmin: false };

function abrirConfirmarEliminar(id, titulo, semana, esAdmin) {
    archivoAEliminar = { id: id, semana: semana, esAdmin: !!esAdmin };
    const titleEl = document.getElementById('delDocTitleDisplay');
    if (titleEl) titleEl.innerText = titulo || ('Archivo #' + id);

    const authBox = document.getElementById('delAuthBox');
    if (authBox) {
        authBox.style.display = esAdmin ? 'none' : 'block';
    }

    const modal = document.getElementById('deleteConfirmModal');
    if (modal) modal.style.display = 'flex';
}

function cerrarConfirmarEliminar() {
    const modal = document.getElementById('deleteConfirmModal');
    if (modal) modal.style.display = 'none';
    archivoAEliminar = { id: null, semana: 1, esAdmin: false };
    const btn = document.getElementById('btnConfirmarDel');
    if (btn) {
        btn.disabled = false;
        btn.innerText = '🗑️ SÍ, ELIMINAR EN SERIO';
    }
}

function confirmarBorradoDefinitivo() {
    if (!archivoAEliminar.id) return;

    const btn = document.getElementById('btnConfirmarDel');
    if (btn) {
        btn.disabled = true;
        btn.innerText = '⏳ ELIMINANDO DE BD Y DISCO...';
    }

    const tokenInput = document.getElementById('delTokenInput');
    const token = tokenInput ? tokenInput.value.trim() : '';

    let url = '<%= ctx %>/archivos/eliminar/' + archivoAEliminar.id + '?format=json&semana=' + archivoAEliminar.semana;
    if (token) {
        url += '&token=' + encodeURIComponent(token);
    }

    fetch(url, {
        method: 'POST',
        headers: { 'X-Requested-With': 'XMLHttpRequest' }
    })
    .then(r => r.json())
    .then(data => {
        if (data && data.success) {
            const idEliminado = archivoAEliminar.id;
            cerrarConfirmarEliminar();

            // Animación suave de salida para la tarjeta eliminada
            const card = document.getElementById('doc-card-' + idEliminado);
            if (card) {
                card.style.transition = 'all 0.45s cubic-bezier(0.4, 0, 0.2, 1)';
                card.style.transform = 'scale(0.85) translateY(-25px)';
                card.style.opacity = '0';
                setTimeout(() => {
                    const parent = card.parentNode;
                    card.remove();
                    // Si el compartimento quedó sin archivos, mostrar slot vacío
                    if (parent && parent.querySelectorAll('.doc-card').length === 0) {
                        const emptyDiv = document.createElement('div');
                        emptyDiv.className = 'empty-slot';
                        emptyDiv.innerHTML = '📭 Sin archivos registrados en este compartimento';
                        parent.appendChild(emptyDiv);
                    }
                }, 450);
            }

            // Actualizar contadores del HUD superior en vivo
            const hudEl = document.getElementById('hudTotalArchivos');
            if (hudEl) {
                let n = parseInt(hudEl.innerText) || 0;
                if (n > 0) hudEl.innerText = (n - 1);
            }

            mostrarToast('🗑️ Archivo eliminado permanentemente de MySQL y del servidor.', 'del');
        } else {
            alert('Aviso: ' + (data && data.message ? data.message : 'No se pudo eliminar. Verifica tu código de Alumna Titular.'));
            if (btn) {
                btn.disabled = false;
                btn.innerText = '🗑️ SÍ, ELIMINAR EN SERIO';
            }
        }
    })
    .catch(err => {
        // Fallback a redirección clásica en caso de falla de red
        window.location.href = '<%= ctx %>/archivos/eliminar/' + archivoAEliminar.id + '?semana=' + archivoAEliminar.semana + (token ? ('&token=' + encodeURIComponent(token)) : '');
    });
}

/* ── TECLADO: CERRAR MODALES CON ESCAPE ──────────────── */
window.addEventListener('keydown', e => {
    if (e.key === 'Escape') {
        closeDocModal();
        cerrarConfirmarEliminar();
        closeAlumnaModal();
    }
});

/* ── MOTOR DE ANIMACIÓN CANVAS DINÁMICO & ANIME INNOVADOR ─ */
const c  = document.getElementById('bgCanvas'),
      cx = c.getContext('2d');
let W = c.width = window.innerWidth,
    H = c.height = window.innerHeight;
window.onresize = () => { W = c.width = window.innerWidth; H = c.height = window.innerHeight; };

// 1. Estrellas cósmicas
const stars = [];
for (let i = 0; i < 110; i++) {
    stars.push({
        x: Math.random()*W, y: Math.random()*H,
        r: Math.random()*1.8 + 0.6,
        vx: (Math.random()-.5)*0.25, vy: (Math.random()-.5)*0.25,
        alpha: Math.random(),
        dAlpha: (Math.random()*0.02 + 0.005) * (Math.random() > .5 ? 1 : -1)
    });
}

// 2. Pétalos de Sakura para el tema Anime Sakura (桜)
const sakuraPetals = [];
for (let i = 0; i < 48; i++) {
    sakuraPetals.push({
        x: Math.random() * W,
        y: Math.random() * H,
        size: Math.random() * 9 + 8,
        angle: Math.random() * Math.PI * 2,
        vAngle: (Math.random() - 0.5) * 0.04,
        flip: Math.random() * Math.PI,
        vFlip: Math.random() * 0.03 + 0.015,
        speedY: Math.random() * 1.4 + 0.8,
        speedX: Math.random() * 1.2 - 0.2,
        wobble: Math.random() * Math.PI * 2,
        wobbleSpeed: Math.random() * 0.03 + 0.02,
        color: ['rgba(255, 182, 217, 0.85)', 'rgba(255, 128, 191, 0.82)', 'rgba(255, 105, 180, 0.78)'][Math.floor(Math.random() * 3)]
    });
}

// 3. Luciérnagas doradas para el tema Ghibli Midnight (ジブリ)
const fireflies = [];
for (let i = 0; i < 20; i++) {
    fireflies.push({
        x: Math.random() * W,
        y: Math.random() * H,
        r: Math.random() * 2.5 + 1.5,
        vx: (Math.random() - 0.5) * 0.7,
        vy: (Math.random() - 0.5) * 0.7,
        alpha: Math.random() * 0.7 + 0.2,
        vAlpha: (Math.random() * 0.03 + 0.01) * (Math.random() > 0.5 ? 1 : -1),
        pulse: Math.random() * Math.PI * 2
    });
}

// 4. Brasas cálidas para el tema Lofi Sunset (夕暮れ)
const lofiEmbers = [];
for (let i = 0; i < 35; i++) {
    lofiEmbers.push({
        x: Math.random() * W,
        y: Math.random() * H,
        r: Math.random() * 2.8 + 1,
        speedY: -(Math.random() * 1.1 + 0.4),
        speedX: (Math.random() - 0.5) * 0.8,
        alpha: Math.random() * 0.7 + 0.3,
        vAlpha: Math.random() * 0.015 + 0.005,
        color: ['#ff7a00', '#ff007f', '#fed7aa', '#ffea00'][Math.floor(Math.random() * 4)]
    });
}

// 4b. Brasas y chispas ardientes para el tema Kimetsu no Yaiba (鬼滅の刃)
const kimetsuEmbers = [];
for (let i = 0; i < 40; i++) {
    kimetsuEmbers.push({
        x: Math.random() * W,
        y: Math.random() * H,
        r: Math.random() * 3 + 1,
        speedY: -(Math.random() * 1.8 + 0.8),
        speedX: (Math.random() - 0.5) * 1.2,
        alpha: Math.random() * 0.8 + 0.2,
        vAlpha: Math.random() * 0.02 + 0.01,
        color: ['#ff3366', '#ff7700', '#00f0a8', '#ffea00'][Math.floor(Math.random() * 4)]
    });
}

// 5. Meteoros celestiales
const meteors = [];
function spawnMeteor() {
    meteors.push({
        x: Math.random()*W*1.2, y: Math.random()*(H*.4),
        len: Math.random()*130+90, speed: Math.random()*8+10,
        angle: Math.PI/4+(Math.random()-.5)*.2,
        life: 1, decay: Math.random()*.025+.015,
        width: Math.random()*2.8+1.5
    });
}
setInterval(() => { if (Math.random() < .6) spawnMeteor(); }, 1600);

// 6. Rastro dinámico de partículas con el cursor
const trail = [];
let mouse = { x: -1000, y: -1000 };
window.addEventListener('mousemove', e => {
    const dx = e.clientX - mouse.x, dy = e.clientY - mouse.y,
          speed = Math.hypot(dx, dy);
    mouse.x = e.clientX; mouse.y = e.clientY;
    for (let i = 0; i < Math.min(Math.floor(speed/3)+2, 7); i++) {
        trail.push({
            x: mouse.x+(Math.random()-.5)*6, y: mouse.y+(Math.random()-.5)*6,
            vx: -dx*.12+(Math.random()-.5)*2, vy: -dy*.12+(Math.random()-.5)*2,
            r: Math.random()*3.5+1.2, alpha: 1,
            decay: Math.random()*.035+.02,
            color: themeParticlePalette[Math.floor(Math.random() * themeParticlePalette.length)]
        });
    }
});

// Función de dibujo de un pétalo de sakura con curvas de Bezier
function drawSakuraPetal(p) {
    cx.save();
    cx.translate(p.x, p.y);
    cx.rotate(p.angle);
    cx.scale(Math.cos(p.flip), 1); // Simulación 3D de rotación en el viento

    cx.beginPath();
    cx.moveTo(0, 0);
    cx.bezierCurveTo(-p.size * 0.5, -p.size * 0.4, -p.size * 0.5, -p.size, 0, -p.size * 1.15);
    cx.bezierCurveTo(p.size * 0.5, -p.size, p.size * 0.5, -p.size * 0.4, 0, 0);
    cx.fillStyle = p.color;
    cx.shadowBlur = 8;
    cx.shadowColor = '#ff66b2';
    cx.fill();
    cx.restore();
}

function bgLoop() {
    cx.clearRect(0, 0, W, H);

    // MODO ANIME SAKURA: Pétalos de cerezo flotando con brisa
    if (currentThemeMode === 'sakura') {
        // Estrellas sutiles rosas
        for (let i = 0; i < stars.length; i++) {
            const s = stars[i];
            s.x += s.vx * 0.5; s.y += s.vy * 0.5; s.alpha += s.dAlpha;
            if (s.alpha <= .1 || s.alpha >= .9) s.dAlpha *= -1;
            if (s.x < 0 || s.x > W) s.vx *= -1;
            if (s.y < 0 || s.y > H) s.vy *= -1;
            cx.beginPath(); cx.arc(s.x, s.y, s.r * 0.85, 0, Math.PI * 2);
            cx.fillStyle = 'rgba(255, 182, 217, ' + (s.alpha * 0.6) + ')';
            cx.fill();
        }

        // Renderizado de pétalos de sakura
        for (let i = 0; i < sakuraPetals.length; i++) {
            const p = sakuraPetals[i];
            p.wobble += p.wobbleSpeed;
            p.x += p.speedX + Math.sin(p.wobble) * 1.1;
            p.y += p.speedY;
            p.angle += p.vAngle;
            p.flip += p.vFlip;

            if (p.y > H + 25) {
                p.y = -20;
                p.x = Math.random() * W;
            }
            if (p.x > W + 20) p.x = -20;
            if (p.x < -20) p.x = W + 20;

            drawSakuraPetal(p);
        }

    // MODO GHIBLI MIDNIGHT: Cielo estrellado + Luciérnagas doradas
    } else if (currentThemeMode === 'ghibli') {
        for (let i = 0; i < stars.length; i++) {
            const s = stars[i];
            s.x += s.vx; s.y += s.vy; s.alpha += s.dAlpha;
            if (s.alpha <= .1 || s.alpha >= 1) s.dAlpha *= -1;
            if (s.x < 0 || s.x > W) s.vx *= -1;
            if (s.y < 0 || s.y > H) s.vy *= -1;
            cx.beginPath(); cx.arc(s.x, s.y, s.r, 0, Math.PI*2);
            cx.fillStyle = themeStarColor + (s.alpha*.85) + ')'; cx.fill();
        }

        // Luciérnagas mágicas Ghibli
        for (let i = 0; i < fireflies.length; i++) {
            const f = fireflies[i];
            f.x += f.vx; f.y += f.vy;
            f.alpha += f.vAlpha;
            if (f.alpha <= 0.1 || f.alpha >= 0.95) f.vAlpha *= -1;
            if (f.x < 0 || f.x > W) f.vx *= -1;
            if (f.y < 0 || f.y > H) f.vy *= -1;

            cx.save();
            cx.beginPath();
            cx.arc(f.x, f.y, f.r, 0, Math.PI * 2);
            cx.fillStyle = 'rgba(251, 191, 36, ' + f.alpha + ')';
            cx.shadowBlur = 18;
            cx.shadowColor = '#fbbf24';
            cx.fill();
            cx.restore();
        }

    // MODO LOFI SUNSET: Brasas cálidas ascendentes
    } else if (currentThemeMode === 'lofi') {
        for (let i = 0; i < lofiEmbers.length; i++) {
            const e = lofiEmbers[i];
            e.y += e.speedY;
            e.x += e.speedX;
            if (e.y < -15) {
                e.y = H + 10;
                e.x = Math.random() * W;
            }
            cx.save();
            cx.beginPath();
            cx.arc(e.x, e.y, e.r, 0, Math.PI * 2);
            cx.fillStyle = e.color;
            cx.globalAlpha = e.alpha;
            cx.shadowBlur = 12;
            cx.shadowColor = e.color;
            cx.fill();
        }

    // MODO KIMETSU NO YAIBA: Brasas ardientes y chispas de fuego místico
    } else if (currentThemeMode === 'kimetsu') {
        for (let i = 0; i < stars.length; i++) {
            const s = stars[i];
            s.x += s.vx * 0.4; s.y += s.vy * 0.4; s.alpha += s.dAlpha;
            if (s.alpha <= .1 || s.alpha >= .9) s.dAlpha *= -1;
            if (s.x < 0 || s.x > W) s.vx *= -1;
            if (s.y < 0 || s.y > H) s.vy *= -1;
            cx.beginPath(); cx.arc(s.x, s.y, s.r * 0.8, 0, Math.PI * 2);
            cx.fillStyle = 'rgba(0, 240, 168, ' + (s.alpha * 0.4) + ')';
            cx.fill();
        }
        for (let i = 0; i < kimetsuEmbers.length; i++) {
            const e = kimetsuEmbers[i];
            e.y += e.speedY;
            e.x += e.speedX + Math.sin(e.y * 0.05) * 0.8;
            if (e.y < -15) {
                e.y = H + 10;
                e.x = Math.random() * W;
            }
            cx.save();
            cx.beginPath();
            cx.arc(e.x, e.y, e.r, 0, Math.PI * 2);
            cx.fillStyle = e.color;
            cx.globalAlpha = e.alpha;
            cx.shadowBlur = 14;
            cx.shadowColor = e.color;
            cx.fill();
            cx.restore();
        }

    // MODO CYBER & MINIMAL ZEN: Constelación con líneas y meteoros
    } else {
        for (let i = 0; i < stars.length; i++) {
            const s = stars[i];
            s.x += s.vx; s.y += s.vy; s.alpha += s.dAlpha;
            if (s.alpha <= .1 || s.alpha >= 1) s.dAlpha *= -1;
            if (s.x < 0 || s.x > W) s.vx *= -1;
            if (s.y < 0 || s.y > H) s.vy *= -1;
            cx.beginPath(); cx.arc(s.x, s.y, s.r, 0, Math.PI*2);
            cx.fillStyle = themeStarColor + (s.alpha*.85) + ')'; cx.fill();
            for (let j = i+1; j < stars.length; j++) {
                const s2 = stars[j], d = Math.hypot(s.x-s2.x, s.y-s2.y);
                if (d < 105) {
                    cx.beginPath(); cx.moveTo(s.x,s.y); cx.lineTo(s2.x,s2.y);
                    cx.strokeStyle = themeStarColor + (.25*(1-d/105)) + ')'; cx.lineWidth=.7; cx.stroke();
                }
            }
        }
    }

    // Cometas / Meteoros celestiales
    for (let i = meteors.length-1; i >= 0; i--) {
        const m = meteors[i];
        const tx = m.x - Math.cos(m.angle)*m.len,
              ty = m.y - Math.sin(m.angle)*m.len;
        const g = cx.createLinearGradient(m.x,m.y,tx,ty);
        const col1 = themeParticlePalette[0] || '#ff77aa';
        const col2 = themeParticlePalette[1] || '#ff1493';
        g.addColorStop(0,   col1);
        g.addColorStop(.35, col2);
        g.addColorStop(1,   'transparent');
        cx.beginPath(); cx.moveTo(m.x,m.y); cx.lineTo(tx,ty);
        cx.strokeStyle=g; cx.lineWidth=m.width*m.life; cx.lineCap='round'; cx.stroke();
        m.x += Math.cos(m.angle)*m.speed; m.y += Math.sin(m.angle)*m.speed;
        m.life -= m.decay;
        if (m.life <= 0) meteors.splice(i,1);
    }

    // Rastro reactivo del cursor del usuario
    for (let i = trail.length-1; i >= 0; i--) {
        const p = trail[i];
        p.x += p.vx; p.y += p.vy; p.alpha -= p.decay; p.r *= .96;
        if (p.alpha <= 0) { trail.splice(i,1); continue; }
        cx.save(); cx.shadowBlur=14; cx.shadowColor=p.color;
        cx.fillStyle=p.color; cx.globalAlpha=p.alpha;
        cx.beginPath(); cx.arc(p.x,p.y,p.r,0,Math.PI*2); cx.fill(); cx.restore();
    }
    requestAnimationFrame(bgLoop);
}
bgLoop();

/* ── INTERACCIÓN 3D TILT EN TARJETAS ─────────────────── */
function initCard3DTilt() {
    const cards = document.querySelectorAll('.cyber-card, .docente-card-pro, .student-id-card, .unit-card, .doc-card');
    cards.forEach(card => {
        card.addEventListener('mousemove', e => {
            const rect = card.getBoundingClientRect();
            const x = e.clientX - rect.left;
            const y = e.clientY - rect.top;
            const centerX = rect.width / 2;
            const centerY = rect.height / 2;
            const rotateX = ((y - centerY) / centerY) * -4.5;
            const rotateY = ((x - centerX) / centerX) * 4.5;
            card.style.transform = `perspective(1000px) rotateX(${rotateX}deg) rotateY(${rotateY}deg) translateY(-4px)`;
        });
        card.addEventListener('mouseleave', () => {
            card.style.transform = '';
        });
    });
}

/* ── LOADER 0→100% (RÁPIDO, FLUIDO Y SIN TRABARSE) ─────── */
<% if (justLoggedIn) { %>
(function() {
    let count = 0;
    const pctEl  = document.getElementById('loaderPct'),
          fillEl = document.getElementById('loaderFill'),
          statEl = document.getElementById('loaderStatus'),
          welcEl = document.getElementById('loaderWelcome'),
          ldrEl  = document.getElementById('cyberLoader');

    function dismissLoader() {
        if (!ldrEl) return;
        ldrEl.style.pointerEvents = 'none';
        ldrEl.style.opacity = '0';
        setTimeout(() => {
            ldrEl.style.display = 'none';
            if (ldrEl.parentNode) ldrEl.parentNode.removeChild(ldrEl);
        }, 250);
    }

    const failsafe = setTimeout(dismissLoader, 1200);

    const timer = setInterval(() => {
        count += 3;
        if (count > 100) count = 100;
        if (pctEl) pctEl.innerText = (count < 10 ? '00' : (count < 100 ? '0' : '')) + count + '%';
        if (fillEl) fillEl.style.width = count + '%';
        if (count === 30 && statEl) statEl.innerText = 'CONECTANDO PERSISTENCIA RELACIONAL...';
        if (count === 65 && statEl) statEl.innerText = 'CARGANDO 16 SEMANAS Y VISTAS ARQUITECTÓNICAS...';
        if (count === 90 && statEl) statEl.innerText = 'INICIALIZANDO MOTOR CIBERNÉTICO...';
        if (count >= 100) {
            clearInterval(timer);
            clearTimeout(failsafe);
            if (statEl) statEl.style.display = 'none';
            if (welcEl) welcEl.style.display = 'block';
            setTimeout(dismissLoader, 250);
        }
    }, 16);
})();
<% } %>

window.addEventListener('DOMContentLoaded', () => {
    // Inicializar tema guardado (default: sakura anime)
    const savedTheme = localStorage.getItem('portfolio_theme') || 'sakura';
    setTheme(savedTheme, false);

    // Inicializar motor de música melódica anime
    initMusicEngine();

    // Inicializar efecto 3D Tilt en tarjetas
    initCard3DTilt();

    if (typeof selectWeek === 'function') {
        selectWeek(curWeek);
    }
});
</script>

</body>
</html>

