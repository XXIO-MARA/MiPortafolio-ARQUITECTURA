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
    <style>
        * { box-sizing: border-box; margin: 0; padding: 0; }
        body { background: #05020c; color: #f5edff; font-family: 'Plus Jakarta Sans', sans-serif; min-height: 100vh; overflow-x: hidden; }
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

        /* ── MICHI ── */
        #cyberCatContainer { position: fixed; bottom: 25px; right: 25px; z-index: 99998; cursor: pointer; display: flex; flex-direction: column; align-items: center; transition: transform .3s; }
        #cyberCatContainer:hover { transform: scale(1.12) translateY(-6px); }
        .cat-bubble { background: rgba(18,6,36,.94); border: 1.5px solid #00f3ff; color: #00f3ff; font-family: 'Fira Code', monospace; font-size: 10.5px; font-weight: 800; padding: 5px 12px; border-radius: 14px; margin-bottom: 8px; box-shadow: 0 0 16px rgba(0,243,255,.45); animation: bubbleBounce 2s ease-in-out infinite alternate; pointer-events: none; white-space: nowrap; }
        .cat-sprite { width: 90px; height: 80px; filter: drop-shadow(0 0 15px rgba(255,0,127,.7)); }
        #michiWindow { position: fixed; bottom: 115px; right: 25px; width: 410px; max-height: 580px; height: 80vh; background: rgba(18,6,36,.96); border: 1.5px solid #d884ff; border-radius: 24px; box-shadow: 0 15px 60px rgba(0,0,0,.85); backdrop-filter: blur(25px); z-index: 99999; display: none; flex-direction: column; overflow: hidden; }
        .michi-head  { background: rgba(30,10,60,.85); border-bottom: 1px solid rgba(216,132,255,.25); padding: 14px 18px; display: flex; justify-content: space-between; align-items: center; }
        .michi-title { font-size: 13.5px; font-weight: 900; color: #00f3ff; font-family: 'Fira Code', monospace; }
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
    </style>
</head>
<body>
<canvas id="bgCanvas"></canvas>

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
        <div class="hud-stat"><span class="pulse-green"></span>ARCHIVOS EN BD: <b><%= totalArchivos %></b></div>
        <div class="hud-stat">DOCUMENTOS: <b><%= totalArchivos %></b></div>
        <div class="hud-stat">PORT: <b>8080</b></div>
        <% if (esAdmin) { %>
            <span class="user-badge-admin">&#127800; ALUMNA TITULAR: <%= nombreAlumna %></span>
            <a href="<%= ctx %>/logout" class="btn-exit">[ CERRAR SESIÓN ]</a>
        <% } else { %>
            <span class="user-badge-est">&#128065;&#65039; MODO AUDITOR</span>
            <a href="<%= ctx %>/login" class="btn-alumna-login" onclick="openAlumnaModal(event)">&#9889; ACCESO ALUMNA (MODIFICAR)</a>
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
        <span class="neon-sub" id="carouselStatus">NAVEGANDO SEMANA 01 DE 16</span>
        <button class="nav-arrow-btn" onclick="changeWeek(1)">SEMANA SIGUIENTE &#9654;</button>
    </div>

    <div class="week-pill-scroller">
    <% for (int s = 1; s <= 16; s++) { %>
        <div class="week-pill <%= s == 1 ? "active-pill" : "" %>"
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
    <div class="week-card <%= s == 1 ? "active-week" : "" %>" id="week-card-<%= s %>">
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
                    String url = ctx + "/archivos/descargar/" + arc.getId();
                %>
                    <div class="doc-card">
                        <div class="doc-title"><%= arc.getTitulo() %></div>
                        <div class="doc-desc"><%= arc.getDescripcion() %></div>
                        <div class="doc-actions">
                            <a href="<%= url %>" class="btn-down" target="_blank">&#128229; Descargar</a>
                            <% if (arc.esVisualizable()) { 
                                String tipoDoc = arc.esPdf() ? "pdf" : (arc.esWord() ? "word" : "doc");
                            %>
                            <button class="btn-view" onclick="openDocModal('<%= url %>','<%= arc.getNombreArchivo() %>','<%= tipoDoc %>')">&#128065;&#65039; Ver <%= arc.esPdf() ? "PDF" : (arc.esWord() ? "Word" : "Doc") %></button>
                            <% } %>
                            <% if (esAdmin) { %>
                            <a href="<%= ctx %>/archivos/eliminar/<%= arc.getId() %>" class="btn-del"
                               onclick="return confirm('¿Eliminar este material?');">&#128465;&#65039;</a>
                            <% } %>
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
                    String url = ctx + "/archivos/descargar/" + arc.getId();
                %>
                    <div class="doc-card" style="border-color:rgba(255,0,127,.35);">
                        <div class="doc-title" style="color:#ff80bf;"><%= arc.getTitulo() %></div>
                        <div class="doc-desc"><%= arc.getDescripcion() %></div>
                        <div class="doc-actions">
                            <a href="<%= url %>" class="btn-down" style="border-color:#ff007f;color:#ff66b2;" target="_blank">&#128229; Descargar Tarea</a>
                            <% if (arc.esVisualizable()) { 
                                String tipoDoc = arc.esPdf() ? "pdf" : (arc.esWord() ? "word" : "doc");
                            %>
                            <button class="btn-view" onclick="openDocModal('<%= url %>','<%= arc.getNombreArchivo() %>','<%= tipoDoc %>')">&#128065;&#65039; Ver <%= arc.esPdf() ? "PDF" : (arc.esWord() ? "Word" : "Doc") %></button>
                            <% } %>
                            <% if (esAdmin) { %>
                            <a href="<%= ctx %>/archivos/eliminar/<%= arc.getId() %>" class="btn-del"
                               onclick="return confirm('¿Eliminar esta tarea?');">&#128465;&#65039;</a>
                            <% } %>
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
     MICHI — Asistente flotante
═══════════════════════════════════════════════════════ --%>
<div id="cyberCatContainer" onclick="toggleMichi()">
    <div class="cat-bubble">&#128062; ¡Miau! ¿Tienes dudas? ¡Tócame!</div>
    <svg class="cat-sprite" viewBox="0 0 100 90" fill="none" xmlns="http://www.w3.org/2000/svg">
        <path d="M 30 65 Q 10 50 15 35 Q 20 20 10 15 Q 5 25 10 40 Q 15 60 30 70 Z" fill="url(#cg)" stroke="#00f3ff" stroke-width="1.5"/>
        <ellipse cx="35" cy="74" rx="10" ry="6" fill="#d884ff" stroke="#ff007f" stroke-width="1.5"/>
        <ellipse cx="68" cy="74" rx="10" ry="6" fill="#d884ff" stroke="#ff007f" stroke-width="1.5"/>
        <ellipse cx="50" cy="58" rx="28" ry="22" fill="url(#cg)" stroke="#d884ff" stroke-width="2"/>
        <path d="M 32 46 Q 50 56 68 46" stroke="#ff007f" stroke-width="3" stroke-linecap="round"/>
        <circle cx="50" cy="52" r="4" fill="#00f3ff"/>
        <polygon points="30,30 22,8 42,20" fill="url(#cg)" stroke="#ff007f" stroke-width="1.5"/>
        <polygon points="70,30 78,8 58,20" fill="url(#cg)" stroke="#ff007f" stroke-width="1.5"/>
        <circle cx="50" cy="32" r="22" fill="url(#cg)" stroke="#d884ff" stroke-width="2"/>
        <ellipse cx="42" cy="30" rx="4.5" ry="6" fill="#00f3ff"/>
        <ellipse cx="58" cy="30" rx="4.5" ry="6" fill="#00f3ff"/>
        <circle cx="43.5" cy="28.5" r="1.8" fill="#fff"/>
        <circle cx="59.5" cy="28.5" r="1.8" fill="#fff"/>
        <polygon points="50,37 47,34 53,34" fill="#ff80df"/>
        <path d="M 47 38 Q 50 41 53 38" stroke="#fff" stroke-width="1.2" stroke-linecap="round"/>
        <path d="M 36 34 L 20 31 M 36 37 L 18 38 M 64 34 L 80 31 M 64 37 L 82 38" stroke="#d884ff" stroke-width="1.2" stroke-linecap="round"/>
        <defs>
            <linearGradient id="cg" x1="0%" y1="0%" x2="100%" y2="100%">
                <stop offset="0%"   stop-color="#d884ff"/>
                <stop offset="60%"  stop-color="#ff007f"/>
                <stop offset="100%" stop-color="#3b0754"/>
            </linearGradient>
        </defs>
    </svg>
</div>

<div id="michiWindow">
    <div class="michi-head">
        <div class="michi-title">&#128062; MICHI // ASISTENTE DEL PORTAFOLIO</div>
        <button onclick="toggleMichi()" style="background:transparent;border:none;color:#ff6688;font-size:16px;cursor:pointer;font-weight:900;">&#10005;</button>
    </div>
    <div class="michi-body" id="michiMessages">
        <div class="michi-msg msg-bot">&#128062; ¡Hola <%= esAdmin ? nombreAlumna : "visitante" %>! Soy <b>Michi</b>, tu asistente.<br><br>
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

<%-- ═══ MODAL VISOR PDF ══════════════════════════════════ --%>
<div id="pdfModal" class="cyber-modal" style="display:none;">
    <div class="modal-dialog">
        <div class="modal-header">
            <div class="modal-title" id="pdfTitle">DOCUMENTO ACADÉMICO</div>
            <button class="modal-close" onclick="document.getElementById('pdfModal').style.display='none';">CERRAR [X]</button>
        </div>
        <iframe id="pdfFrame" src="" style="width:100%;height:72vh;border:none;border-radius:14px;background:#fff;"></iframe>
    </div>
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

<%-- ═══ MODAL ACCESO ALUMNA (MODIFICAR) ═════════════════ --%>
<% if (!esAdmin) { %>
<div id="alumnaModal" class="cyber-modal" style="display:none;">
    <div class="modal-dialog" style="max-width:440px;">
        <div class="modal-header">
            <div class="modal-title">&#9889; ACCESO DE ALUMNA TITULAR</div>
            <button class="modal-close" onclick="closeAlumnaModal()">&times;</button>
        </div>
        <form action="<%= ctx %>/login" method="POST">
            <label style="font-size:11.5px;font-family:'Fira Code',monospace;color:#00f3ff;display:block;margin-bottom:6px;font-weight:700;">CÓDIGO O CELULAR (FLOR XIOMARA):</label>
            <input type="text" name="codigo" id="modalCodigoInput" class="cyber-input" value="ADMIN949163067" required autofocus style="color:#00f3ff;letter-spacing:1px;font-weight:700;">
            <div style="font-size:10.5px;color:#d884ff;margin:8px 0 16px;font-family:'Fira Code',monospace;">
                &#128161; Válidos: <b>ADMIN949163067</b> &bull; Celular: <b>949163067</b> &bull; Código: <b>s01269h</b>
            </div>
            <button type="submit" class="submit-btn" style="background:linear-gradient(135deg, #d884ff 0%, #ff007f 100%);">
                &#9889; INGRESAR Y HABILITAR MODIFICACIONES
            </button>
            <div style="margin-top:14px;text-align:center;">
                <a href="<%= ctx %>/login?alumna=1" style="font-family:'Fira Code',monospace;font-size:11px;color:#00f3ff;text-decoration:none;">
                    &rarr; O entrar en 1 Clic Directo sin escribir &larr;
                </a>
            </div>
        </form>
    </div>
</div>
<% } %>

<%-- ═══════════════════════════════════════════════════════
     JAVASCRIPT
═══════════════════════════════════════════════════════ --%>
<script>
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
let curWeek = 1;

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
}

function changeWeek(d) {
    let next = curWeek + d;
    if (next < 1)  next = 16;
    if (next > 16) next = 1;
    selectWeek(next);
}

/* ── MICHI ────────────────────────────────────────────── */
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
        let resp = '¡Miau! 🐾 No tengo esa consulta exacta, pero puedes revisar las 16 semanas en el carrusel o consultar el correo de Flor.';
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

/* ── MODAL VISOR DOCUMENTO (PDF / WORD / DOC) ────────── */
function openDocModal(url, title, type) {
    document.getElementById('pdfTitle').innerText = 'DOCUMENTO: ' + title;
    let targetUrl = url;
    if (type === 'word') {
        const fullUrl = url.startsWith('http') ? url : (window.location.origin + url);
        targetUrl = 'https://view.officeapps.live.com/op/embed.aspx?src=' + encodeURIComponent(fullUrl);
    }
    document.getElementById('pdfFrame').src = targetUrl;
    document.getElementById('pdfModal').style.display = 'flex';
}

function openPdfModal(url, title) {
    openDocModal(url, title, 'pdf');
}

/* ── FONDO CÓSMICO ────────────────────────────────────── */
const c  = document.getElementById('bgCanvas'),
      cx = c.getContext('2d');
let W = c.width = window.innerWidth,
    H = c.height = window.innerHeight;
window.onresize = () => { W = c.width = window.innerWidth; H = c.height = window.innerHeight; };

const stars = [];
for (let i = 0; i < 110; i++) {
    stars.push({
        x: Math.random()*W, y: Math.random()*H,
        r: Math.random()*2+.8,
        vx: (Math.random()-.5)*.35, vy: (Math.random()-.5)*.35,
        alpha: Math.random(),
        dAlpha: (Math.random()*.02+.005) * (Math.random()>.5?1:-1)
    });
}

const meteors = [];
function spawnMeteor() {
    meteors.push({
        x: Math.random()*W*1.2, y: Math.random()*(H*.4),
        len: Math.random()*130+90, speed: Math.random()*9+12,
        angle: Math.PI/4+(Math.random()-.5)*.2,
        life: 1, decay: Math.random()*.025+.015,
        width: Math.random()*2.8+1.5
    });
}
setInterval(() => { if (Math.random() < .7) spawnMeteor(); }, 1500);

const trail = [];
let mouse = { x: -1000, y: -1000 };
window.addEventListener('mousemove', e => {
    const dx = e.clientX - mouse.x, dy = e.clientY - mouse.y,
          speed = Math.hypot(dx, dy);
    mouse.x = e.clientX; mouse.y = e.clientY;
    for (let i = 0; i < Math.min(Math.floor(speed/3)+2, 8); i++) {
        trail.push({
            x: mouse.x+(Math.random()-.5)*6, y: mouse.y+(Math.random()-.5)*6,
            vx: -dx*.12+(Math.random()-.5)*2, vy: -dy*.12+(Math.random()-.5)*2,
            r: Math.random()*3.5+1.2, alpha: 1,
            decay: Math.random()*.035+.02,
            color: Math.random()>.5?'#00f3ff':(Math.random()>.5?'#ff007f':'#d884ff')
        });
    }
});

function bgLoop() {
    cx.clearRect(0, 0, W, H);

    for (let i = 0; i < stars.length; i++) {
        const s = stars[i];
        s.x += s.vx; s.y += s.vy; s.alpha += s.dAlpha;
        if (s.alpha <= .1 || s.alpha >= 1) s.dAlpha *= -1;
        if (s.x < 0 || s.x > W) s.vx *= -1;
        if (s.y < 0 || s.y > H) s.vy *= -1;
        cx.beginPath(); cx.arc(s.x, s.y, s.r, 0, Math.PI*2);
        cx.fillStyle = `rgba(216,132,255,${s.alpha*.85})`; cx.fill();
        for (let j = i+1; j < stars.length; j++) {
            const s2 = stars[j], d = Math.hypot(s.x-s2.x, s.y-s2.y);
            if (d < 105) {
                cx.beginPath(); cx.moveTo(s.x,s.y); cx.lineTo(s2.x,s2.y);
                cx.strokeStyle = `rgba(216,132,255,${.25*(1-d/105)})`; cx.lineWidth=.7; cx.stroke();
            }
        }
    }

    for (let i = meteors.length-1; i >= 0; i--) {
        const m = meteors[i];
        const tx = m.x - Math.cos(m.angle)*m.len,
              ty = m.y - Math.sin(m.angle)*m.len;
        const g = cx.createLinearGradient(m.x,m.y,tx,ty);
        g.addColorStop(0,   `rgba(0,243,255,${m.life})`);
        g.addColorStop(.35, `rgba(216,132,255,${m.life*.85})`);
        g.addColorStop(1,   'transparent');
        cx.beginPath(); cx.moveTo(m.x,m.y); cx.lineTo(tx,ty);
        cx.strokeStyle=g; cx.lineWidth=m.width*m.life; cx.lineCap='round'; cx.stroke();
        m.x += Math.cos(m.angle)*m.speed; m.y += Math.sin(m.angle)*m.speed;
        m.life -= m.decay;
        if (m.life <= 0) meteors.splice(i,1);
    }

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

    // Failsafe absoluto de 1.2 segundos: se retira sí o sí
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
</script>

</body>
</html>

