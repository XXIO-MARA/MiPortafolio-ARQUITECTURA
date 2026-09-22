package com.miportafolio.controller;

import com.miportafolio.config.DatabaseConfig;
import com.miportafolio.service.AuthService;
import com.miportafolio.model.Usuario;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;

/**
 * LoginServlet — autenticación del portafolio.
 *
 * GET  /login → muestra login.jsp
 * POST /login → valida código, crea sesión y redirige al portafolio
 */
@WebServlet(name = "LoginServlet", urlPatterns = {"/login"})
public class LoginServlet extends HttpServlet {

    private final AuthService authService = new AuthService();

    /* ── Inicializar BD al arrancar la app ──────────────── */
    @Override
    public void init() throws ServletException {
        super.init();
        try {
            DatabaseConfig.init();
        } catch (Exception e) {
            System.err.println("[LoginServlet] AVISO: BD no disponible en el arranque: " + e.getMessage());
        }
    }

    /* ── GET: mostrar formulario de login ───────────────── */
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {

        // Si se pasa ?alumna=1 o ?admin=1, autenticar directamente como Alumna Titular
        String fastAdmin = req.getParameter("alumna");
        if (fastAdmin == null) fastAdmin = req.getParameter("admin");
        if ("1".equals(fastAdmin) || "true".equalsIgnoreCase(fastAdmin)) {
            Usuario alumna = authService.login("ADMIN949163067");
            if (alumna != null) {
                HttpSession session = req.getSession(true);
                session.setAttribute("usuario", alumna);
                session.setAttribute("justLoggedIn", Boolean.TRUE);
                res.sendRedirect(req.getContextPath() + "/portafolio");
                return;
            }
        }

        HttpSession session = req.getSession(false);
        if (session != null && session.getAttribute("usuario") != null) {
            Usuario u = (Usuario) session.getAttribute("usuario");
            // Si ya es la alumna titular (admin), va a su portafolio
            if (u != null && u.esAdmin()) {
                res.sendRedirect(req.getContextPath() + "/portafolio");
                return;
            }
            // Si es un visitante/auditor que desea identificarse como alumna,
            // cerramos la sesión temporal para mostrar el formulario de login
            session.invalidate();
        }
        req.getRequestDispatcher("/login.jsp").forward(req, res);
    }

    /* ── POST: procesar autenticación ───────────────────── */
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {

        req.setCharacterEncoding("UTF-8");

        // Acepta campo "codigo" o "username"
        String clave = req.getParameter("codigo");
        if (clave == null || clave.isBlank()) {
            clave = req.getParameter("username");
        }

        Usuario usuario = authService.login(clave);

        if (usuario != null) {
            // Sincronizar datos fijos del admin cada vez que entra
            if (usuario.esAdmin()) {
                usuario.setNombre("Flor Xiomara Medina Salazar");
                usuario.setCorreo("s01269h@upla.edu.pe");
            }

            HttpSession session = req.getSession(true);
            session.setAttribute("usuario",     usuario);
            session.setAttribute("justLoggedIn", Boolean.TRUE);
            res.sendRedirect(req.getContextPath() + "/portafolio");

        } else {
            res.sendRedirect(req.getContextPath() + "/login?error=true");
        }
    }
}
