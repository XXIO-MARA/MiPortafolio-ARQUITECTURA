package com.miportafolio.controller;

import com.miportafolio.service.AuthService;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;

/**
 * RegistroServlet — registro de nuevos usuarios.
 *
 * GET  /registro → muestra registro.jsp
 * POST /registro → valida datos, guarda en BD y redirige al login
 */
@WebServlet(name = "RegistroServlet", urlPatterns = {"/registro"})
public class RegistroServlet extends HttpServlet {

    private final AuthService authService = new AuthService();

    /* ── GET ─────────────────────────────────────────────── */
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {

        HttpSession session = req.getSession(false);
        if (session != null && session.getAttribute("usuario") != null) {
            res.sendRedirect(req.getContextPath() + "/portafolio");
            return;
        }
        req.getRequestDispatcher("/registro.jsp").forward(req, res);
    }

    /* ── POST ────────────────────────────────────────────── */
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {

        req.setCharacterEncoding("UTF-8");

        String codigo = req.getParameter("codigo");
        String nombre = req.getParameter("nombre");
        String correo = req.getParameter("correo");

        // Validación básica
        if (codigo == null || codigo.isBlank()
         || nombre  == null || nombre.isBlank()) {
            res.sendRedirect(req.getContextPath() + "/registro?error=campos");
            return;
        }

        boolean ok = authService.registrar(codigo, nombre, correo);

        if (ok) {
            res.sendRedirect(req.getContextPath() + "/login?ok=1");
        } else {
            res.sendRedirect(req.getContextPath() + "/registro?error=duplicado");
        }
    }
}
