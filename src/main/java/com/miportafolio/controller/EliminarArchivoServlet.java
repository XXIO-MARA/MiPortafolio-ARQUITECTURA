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
    protected void doGet(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {

        HttpSession session = req.getSession(false);
        Usuario usuario = (session != null)
                ? (Usuario) session.getAttribute("usuario")
                : null;

        if (usuario == null || !usuario.esAdmin()) {
            res.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        int id = resolverIdDesdeUrl(req);
        if (id <= 0) {
            res.sendRedirect(req.getContextPath() + "/portafolio?tab=archivos");
            return;
        }

        // Buscar archivo ANTES de borrar (para eliminar fichero físico)
        Archivo archivo = archivoDAO.buscarPorId(id);
        if (archivo != null) {
            // Borrar fichero físico del disco
            String uploadDir = getServletContext().getRealPath("/uploads");
            new StorageService(uploadDir).eliminar(archivo.getUrlArchivo());
            // Borrar registro de BD
            archivoDAO.eliminar(id);
        }

        res.sendRedirect(req.getContextPath()
                + "/portafolio?tab=archivos&msg=del_ok");
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
