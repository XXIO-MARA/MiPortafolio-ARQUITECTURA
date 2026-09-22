<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%
    /* Redirección automática inmediata al Portafolio Oficial */
    response.sendRedirect(request.getContextPath() + "/visitar");
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta http-equiv="refresh" content="0;url=<%= request.getContextPath() %>/visitar">
    <title>Accediendo al Portafolio &bull; UPLA 2026-I</title>
    <link href="https://fonts.googleapis.com/css2?family=Fira+Code:wght@700;900&display=swap" rel="stylesheet">
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body {
            background: #05020c;
            color: #00f3ff;
            font-family: 'Fira Code', monospace;
            display: flex;
            align-items: center;
            justify-content: center;
            height: 100vh;
            overflow: hidden;
        }
        .cyber-portal {
            text-align: center;
            padding: 40px;
            border: 1.8px solid #00f3ff;
            border-radius: 28px;
            background: rgba(18, 6, 36, 0.92);
            box-shadow: 0 0 50px rgba(0, 243, 255, 0.45), inset 0 0 25px rgba(255, 0, 127, 0.2);
            max-width: 440px;
            width: 90%;
        }
        .cyber-spinner {
            width: 60px;
            height: 60px;
            border: 3px dashed #00f3ff;
            border-radius: 50%;
            animation: spin 1s linear infinite;
            margin: 0 auto 20px;
            box-shadow: 0 0 25px #ff007f;
        }
        @keyframes spin { 100% { transform: rotate(360deg); } }
        h1 {
            font-size: 18px;
            color: #fff;
            text-shadow: 0 0 15px #d884ff;
            margin-bottom: 10px;
            font-weight: 900;
        }
        p {
            color: #00f3ff;
            font-size: 12px;
            letter-spacing: 1.2px;
        }
    </style>
</head>
<body>
    <div class="cyber-portal">
        <div class="cyber-spinner"></div>
        <h1>ACCEDIENDO AL PORTAFOLIO...</h1>
        <p>UNIVERSIDAD PERUANA LOS ANDES &bull; 2026-I</p>
    </div>
    <script>
        window.location.replace('<%= request.getContextPath() %>/visitar');
    </script>
</body>
</html>
