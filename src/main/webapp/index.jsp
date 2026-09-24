<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%
    /* Redirección directa e inmediata al Portafolio */
    response.sendRedirect(request.getContextPath() + "/visitar");
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta http-equiv="refresh" content="0;url=<%= request.getContextPath() %>/visitar">
    <title>Cargando Portafolio &bull; UPLA 2026-I</title>
    <script>window.location.replace('<%= request.getContextPath() %>/visitar');</script>
</head>
<body style="background:#05020c;margin:0;"></body>
</html>
