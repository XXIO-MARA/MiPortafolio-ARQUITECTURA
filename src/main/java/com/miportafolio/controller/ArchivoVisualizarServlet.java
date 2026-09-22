package com.miportafolio.controller;

import com.miportafolio.dao.ArchivoDAO;
import com.miportafolio.model.Archivo;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.*;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;

/**
 * ArchivoVisualizarServlet — sirve archivos para visualización INLINE.
 *
 * GET /archivos/ver/{id} o /archivos/ver?id={id}
 *
 * A diferencia de DescargarArchivoServlet, este siempre intenta
 * abrir el archivo en el navegador (inline) en lugar de forzar
 * la descarga. Ideal para el visor de PDFs integrado en el dashboard.
 */
@WebServlet(name = "ArchivoVisualizarServlet",
            urlPatterns = {"/archivos/ver", "/archivos/ver/*"})
public class ArchivoVisualizarServlet extends HttpServlet {

    private final ArchivoDAO archivoDAO = new ArchivoDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {

        int id = resolverIdDesdeUrl(req);
        if (id <= 0) {
            res.sendError(HttpServletResponse.SC_BAD_REQUEST, "ID inválido");
            return;
        }

        Archivo archivo = archivoDAO.buscarPorId(id);
        if (archivo == null) {
            res.sendError(HttpServletResponse.SC_NOT_FOUND, "Archivo no encontrado");
            return;
        }

        // Si el archivo está en Supabase Storage (URL pública), redirigir directamente
        if (archivo.getUrlArchivo() != null && archivo.getUrlArchivo().startsWith("http")) {
            res.sendRedirect(archivo.getUrlArchivo());
            return;
        }

        // Buscar fichero físico
        String uploadDir = getServletContext().getRealPath("/uploads");
        File f = new File(uploadDir, archivo.getUrlArchivo());
        if (!f.exists()) {
            res.sendError(HttpServletResponse.SC_NOT_FOUND, "Fichero físico no encontrado");
            return;
        }

        // Detectar MIME y servir siempre inline
        String nombre      = archivo.getNombreArchivo().toLowerCase();
        String contentType = detectarMime(nombre);
        String encoded     = URLEncoder.encode(archivo.getNombreArchivo(), StandardCharsets.UTF_8)
                                       .replace("+", "%20");

        res.setContentType(contentType);
        res.setContentLengthLong(f.length());
        res.setHeader("Content-Disposition",
                "inline; filename=\"" + archivo.getNombreArchivo()
                + "\"; filename*=UTF-8''" + encoded);
        res.setHeader("X-Content-Type-Options", "nosniff");
        res.setHeader("Cache-Control", "public, max-age=3600");

        // Streaming
        try (InputStream in  = new BufferedInputStream(new FileInputStream(f));
             OutputStream out = res.getOutputStream()) {
            byte[] buf = new byte[8192];
            int read;
            while ((read = in.read(buf)) != -1) out.write(buf, 0, read);
        }
    }

    /* ── helpers ─────────────────────────────────────────── */

    private String detectarMime(String nombre) {
        if (nombre.endsWith(".pdf"))  return "application/pdf";
        if (nombre.endsWith(".png"))  return "image/png";
        if (nombre.endsWith(".jpg") || nombre.endsWith(".jpeg")) return "image/jpeg";
        if (nombre.endsWith(".gif"))  return "image/gif";
        if (nombre.endsWith(".webp")) return "image/webp";
        return "application/octet-stream";
    }

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
