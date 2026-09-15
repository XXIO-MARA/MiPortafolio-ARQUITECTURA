package com.miportafolio.controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;

/**
 * ContactoServlet — Procesa los mensajes enviados al buzón institucional
 * de la alumna titular Flor Xiomara Medina Salazar (s01269h@upla.edu.pe).
 *
 * Mapeado en /contacto/enviar
 */
@WebServlet(name = "ContactoServlet", urlPatterns = {"/contacto/enviar"})
public class ContactoServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        String mensaje = req.getParameter("mensaje");

        if (mensaje != null && !mensaje.isBlank()) {
            System.out.println("[BUZÓN INSTITUCIONAL UPLA] Mensaje recibido para Flor: " + mensaje.trim());
        }

        // Redireccionar a la pestaña de contacto con la alerta de confirmación
        res.sendRedirect(req.getContextPath() + "/portafolio?tab=contacto&msg=msg_enviado");
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {
        res.sendRedirect(req.getContextPath() + "/portafolio?tab=contacto");
    }
}