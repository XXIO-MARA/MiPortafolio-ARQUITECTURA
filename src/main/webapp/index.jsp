<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%
    /* Redirección al Login o Portafolio según estado de sesión */
    if (session != null && session.getAttribute("usuario") != null) {
        response.sendRedirect(request.getContextPath() + "/portafolio");
        return;
    }
    response.sendRedirect(request.getContextPath() + "/login");
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta http-equiv="refresh" content="0;url=<%= request.getContextPath() %>/login">
    <title>Acceso al Portafolio &bull; UPLA 2026-I</title>
    <script>window.location.replace('<%= request.getContextPath() %>/login');</script>
</head>
<body style="background:#05020c;margin:0;"></body>
</html>
