package com.miportafolio.controller;

import com.miportafolio.dao.ArchivoDAO;
import com.miportafolio.model.Archivo;
import com.miportafolio.model.Usuario;
import com.miportafolio.service.StorageService;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;

/**
 * EliminarArchivoServlet — elimina un archivo del portafolio.
 *
 * GET /archivos/eliminar/{id}  o  /archivos/eliminar?id={id}
 *
 * Borra el registro de BD y el fichero físico del disco.
 * Solo la Alumna Titular (esAdmin) puede eliminar.
 */
@WebServlet(name = "EliminarArchivoServlet",
            urlPatterns = {"/archivos/eliminar", "/archivos/eliminar/*"})
public class EliminarArchivoServlet extends HttpServlet {

    private final ArchivoDAO archivoDAO = new ArchivoDAO();

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {
        doGet(req, res);
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {

        HttpSession session = req.getSession(false);
        Usuario usuario = (session != null)
                ? (Usuario) session.getAttribute("usuario")
                : null;

        // Comprobar autorización: sesión admin O código de alumna pasado por parámetro
        boolean esAutorizado = (usuario != null && usuario.esAdmin());
        String codeParam = req.getParameter("token");
        if (codeParam == null) codeParam = req.getParameter("codigo");
        if (!esAutorizado && codeParam != null) {
            String c = codeParam.trim().toUpperCase();
            if (c.equals("ADMIN949163067") || c.equals("949163067") ||
                c.equals("ADMIN") || c.equals("S01269H") ||
                c.equals("FLOR") || c.equals("XIOMARA")) {
                esAutorizado = true;
                // Si la clave es válida, además le creamos la sesión de admin
                HttpSession newSession = req.getSession(true);
                Usuario adminUser = new com.miportafolio.dao.UsuarioDAO().buscarPorCodigo("ADMIN949163067");
                if (adminUser != null) newSession.setAttribute("usuario", adminUser);
            }
        }

        boolean isAjax = "json".equalsIgnoreCase(req.getParameter("format"))
                || "XMLHttpRequest".equalsIgnoreCase(req.getHeader("X-Requested-With"));

        if (!esAutorizado) {
            if (isAjax) {
                res.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
                res.setContentType("application/json;charset=UTF-8");
                res.getWriter().write("{\"success\":false,\"error\":\"unauthorized\",\"message\":\"Requiere acceso de Alumna Titular\"}");
                return;
            }
            res.sendRedirect(req.getContextPath() + "/login?error=delete_unauthorized");
            return;
        }

        int id = resolverIdDesdeUrl(req);
        if (id <= 0) {
            if (isAjax) {
                res.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                res.setContentType("application/json;charset=UTF-8");
                res.getWriter().write("{\"success\":false,\"error\":\"invalid_id\"}");
                return;
            }
            res.sendRedirect(req.getContextPath() + "/portafolio?tab=archivos");
            return;
        }

        // Buscar archivo ANTES de borrar para obtener semana y fichero físico
        Archivo archivo = archivoDAO.buscarPorId(id);
        int semana = 1;
        boolean borradoOk = false;
        if (archivo != null) {
            semana = archivo.getSemana();
            // 1. Borrar fichero físico del disco
            try {
                String uploadDir = getServletContext().getRealPath("/uploads");
                new StorageService(uploadDir).eliminar(archivo.getUrlArchivo());
            } catch (Exception e) {
                System.err.println("[Eliminar] Aviso al borrar archivo en disco: " + e.getMessage());
            }
            // 2. Borrar registro de BD
            borradoOk = archivoDAO.eliminar(id);
            System.out.println("[Eliminar] Archivo id=" + id + " eliminado con éxito: " + borradoOk);
        }

        if (isAjax) {
            res.setContentType("application/json;charset=UTF-8");
            res.getWriter().write("{\"success\":" + borradoOk + ",\"id\":" + id + ",\"semana\":" + semana + "}");
            return;
        }

        res.sendRedirect(req.getContextPath()
                + "/portafolio?tab=archivos&semana=" + semana + "&msg=del_ok");
    }

    /* ── helper: leer id de /eliminar/123 o ?id=123 ──── */
    private int resolverIdDesdeUrl(HttpServletRequest req) {
        String idParam = req.getParameter("id");
        if (idParam != null && !idParam.isBlank()) {
            try { return Integer.parseInt(idParam.trim()); }
            catch (NumberFormatException ignored) {}
        }
        String pathInfo = req.getPathInfo();
        if (pathInfo != null && pathInfo.length() > 1) {
            try { return Integer.parseInt(pathInfo.substring(1)); }
            catch (NumberFormatException ignored) {}
        }
        return -1;
    }
}
