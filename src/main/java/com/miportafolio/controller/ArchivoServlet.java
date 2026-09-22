package com.miportafolio.controller;

import com.miportafolio.dao.ArchivoDAO;
import com.miportafolio.model.Archivo;
import com.miportafolio.model.Usuario;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.List;

/**
 * ArchivoServlet — controlador principal del portafolio.
 *
 * GET  /portafolio → carga datos desde BD y hace forward a dashboard.jsp
 * POST /portafolio → maneja acciones adicionales (actualizar perfil)
 *
 * Temas oficiales de las 16 semanas del sílabo UPLA 2026-I.
 */
@WebServlet(name = "ArchivoServlet", urlPatterns = {"/portafolio", "/archivos"})
public class ArchivoServlet extends HttpServlet {

    private final ArchivoDAO archivoDAO = new ArchivoDAO();

    /** Temas oficiales del sílabo — compartidos con el dashboard.jsp */
    public static final String[] TEMAS_SEMANAS = {
        "Conceptos Fundamentales de la Arquitectura de Software y Ciclo de Vida",
        "Requerimientos Arquitectónicos y Atributos de Calidad (ISO/IEC 25010)",
        "Escenarios de Atributos de Calidad y Árbol de Utilidad (Utility Tree)",
        "Modelo de 4+1 Vistas de Philippe Kruchten y Diagramas de Despliegue",
        "Estilos Arquitectónicos: Capas, MVC, Hexagonal y Microkernel",
        "Arquitectura Orientada a Servicios (SOA) y APIs RESTful",
        "Arquitectura de Microservicios: Descomposición y Patrones de Integración",
        "Evaluación Parcial y Consolidación del Portafolio Arquitectónico Fase I",
        "Patrones de Diseño Arquitectónico Estructurales y Creacionales",
        "Tácticas de Arquitectura para Disponibilidad, Tolerancia a Fallos y Rendimiento",
        "Tácticas de Seguridad de Datos, Cifrado y Mantenibilidad",
        "Método de Evaluación de Arquitecturas de Software (ATAM)",
        "Arquitecturas Cloud Native, Contenedores Docker y Microservicios en la Nube",
        "Documentación Arquitectónica: Modelo C4 y Plantillas Estándar arc42",
        "Métricas de Calidad de Software, Refactorización y Deuda Técnica",
        "Sustentación Final del Portafolio de Arquitectura de Software 2026-I"
    };

    /* ── GET ─────────────────────────────────────────────── */

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {

        HttpSession session = req.getSession(false);
        Usuario usuario = (session != null)
                ? (Usuario) session.getAttribute("usuario")
                : null;

        if (usuario == null) {
            res.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        // Nombre para mostrar (nunca muestra "visitante/auditor" como alumna)
        String nombreAlumna = "Flor Xiomara Medina Salazar";
        String nom = usuario.getNombre();
        if (nom != null
                && !nom.toLowerCase().contains("visitante")
                && !nom.toLowerCase().contains("auditor")
                && !nom.toLowerCase().contains("docente")) {
            nombreAlumna = nom;
        }

        // Loader animado solo en primer acceso tras login
        boolean justLoggedIn = Boolean.TRUE.equals(session.getAttribute("justLoggedIn"));
        if (justLoggedIn) session.removeAttribute("justLoggedIn");

        // Parámetros de navegación
        String tab = req.getParameter("tab");
        if (tab == null || tab.isBlank()) tab = "presentacion";
        String msg = req.getParameter("msg");

        // Datos desde BD
        List<Archivo> archivos = archivoDAO.listar();

        // Pasar atributos a la vista JSP
        req.setAttribute("usuario",       usuario);
        req.setAttribute("esAdmin",       usuario.esAdmin());
        req.setAttribute("nombreAlumna",  nombreAlumna);
        req.setAttribute("justLoggedIn",  justLoggedIn);
        req.setAttribute("activeTab",     tab);
        req.setAttribute("msg",           msg);
        req.setAttribute("archivos",      archivos);
        req.setAttribute("totalArchivos", archivos.size());
        req.setAttribute("temasSemanas",  TEMAS_SEMANAS);

        req.getRequestDispatcher("/dashboard.jsp").forward(req, res);
    }

    /* ── POST ────────────────────────────────────────────── */

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {

        req.setCharacterEncoding("UTF-8");
        HttpSession session = req.getSession(false);
        Usuario usuario = (session != null)
                ? (Usuario) session.getAttribute("usuario")
                : null;

        if (usuario == null || !usuario.esAdmin()) {
            res.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        // Acción: actualizar nombre del perfil
        String action = req.getParameter("action");
        if ("actualizar_perfil".equalsIgnoreCase(action)) {
            String nuevoNombre = req.getParameter("nombre");
            if (nuevoNombre != null && !nuevoNombre.isBlank()) {
                usuario.setNombre(nuevoNombre.trim());
                session.setAttribute("usuario", usuario);
                res.sendRedirect(req.getContextPath()
                        + "/portafolio?tab=presentacion&msg=perfil_actualizado");
                return;
            }
        }

        res.sendRedirect(req.getContextPath() + "/portafolio");
    }
}
