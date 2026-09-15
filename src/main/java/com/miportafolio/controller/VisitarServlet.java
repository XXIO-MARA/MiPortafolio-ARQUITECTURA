package com.miportafolio.controller;

import com.miportafolio.dao.UsuarioDAO;
import com.miportafolio.model.Usuario;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;

/**
 * VisitarServlet — acceso rápido en modo auditor/visitante.
 *
 * GET /visitar → inicia sesión automáticamente con la cuenta
 *                EST2026 (Visitante Académico / Auditor UPLA)
 *                sin necesidad de ingresar contraseña.
 *
 * Útil para que el docente pueda revisar el portafolio
 * sin necesitar el código del alumno.
 */
@WebServlet(name = "VisitarServlet", urlPatterns = {"/visitar"})
public class VisitarServlet extends HttpServlet {

    private static final String CODIGO_VISITANTE = "EST2026";
    private final UsuarioDAO usuarioDAO = new UsuarioDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {

        HttpSession session = req.getSession(false);

        // Si ya hay sesión activa, redirigir directo al portafolio
        if (session != null && session.getAttribute("usuario") != null) {
            res.sendRedirect(req.getContextPath() + "/portafolio");
            return;
        }

        // Buscar el usuario visitante en BD
        Usuario visitante = null;
        try {
            visitante = usuarioDAO.buscarPorCodigo(CODIGO_VISITANTE);
        } catch (Exception ignored) {}

        if (visitante == null) {
            // Fallback seguro en memoria si la base de datos no está activa
            visitante = new Usuario(2, CODIGO_VISITANTE, "Visitante Académico / Auditor UPLA", "auditor@upla.edu.pe", 2);
        }

        // Crear sesión en modo visitante / sin contraseña
        HttpSession nuevaSesion = req.getSession(true);
        nuevaSesion.setAttribute("usuario", visitante);
        nuevaSesion.setAttribute("justLoggedIn", Boolean.TRUE);
        res.sendRedirect(req.getContextPath() + "/portafolio");
    }
}
