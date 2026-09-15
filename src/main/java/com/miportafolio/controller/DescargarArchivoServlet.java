package com.miportafolio.controller;

import com.miportafolio.dao.ArchivoDAO;
import com.miportafolio.model.Archivo;
import com.miportafolio.service.StorageService;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.*;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;

/**
 * DescargarArchivoServlet — sirve archivos para descarga o visualización.
 *
 * GET /archivos/descargar/{id}  o  /archivos/descargar?id={id}
 *
 * PDFs e imágenes → inline (se abren en el navegador).
 * Resto           → attachment (fuerza descarga).
 */
@WebServlet(name = "DescargarArchivoServlet",
            urlPatterns = {"/archivos/descargar", "/archivos/descargar/*"})
public class DescargarArchivoServlet extends HttpServlet {

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

        String uploadDir = getServletContext().getRealPath("/uploads");
        StorageService storage = new StorageService(uploadDir);
        File f = storage.getFile(archivo.getUrlArchivo());

        if (!f.exists() || !f.isFile()) {
            res.sendError(HttpServletResponse.SC_NOT_FOUND, "Fichero físico no existe");
            return;
        }

        // ── Content-Type y disposición ───────────────────
        String nombre      = archivo.getNombreArchivo().toLowerCase();
        String contentType;
        String disposition;

        if (nombre.endsWith(".pdf")) {
            contentType = "application/pdf";         disposition = "inline";
        } else if (nombre.endsWith(".png")) {
            contentType = "image/png";               disposition = "inline";
        } else if (nombre.endsWith(".jpg") || nombre.endsWith(".jpeg")) {
            contentType = "image/jpeg";              disposition = "inline";
        } else if (nombre.endsWith(".docx")) {
            contentType = "application/vnd.openxmlformats-officedocument.wordprocessingml.document";
            disposition = "attachment";
        } else if (nombre.endsWith(".pptx")) {
            contentType = "application/vnd.openxmlformats-officedocument.presentationml.presentation";
            disposition = "attachment";
        } else if (nombre.endsWith(".zip")) {
            contentType = "application/zip";         disposition = "attachment";
        } else {
            contentType = "application/octet-stream"; disposition = "attachment";
        }

        String encodedName = URLEncoder.encode(
                archivo.getNombreArchivo(), StandardCharsets.UTF_8)
                .replace("+", "%20");

        res.setContentType(contentType);
        res.setContentLengthLong(f.length());
        res.setHeader("Content-Disposition",
                disposition + "; filename=\"" + archivo.getNombreArchivo()
                + "\"; filename*=UTF-8''" + encodedName);

        // ── Streaming ────────────────────────────────────
        try (InputStream in  = new BufferedInputStream(new FileInputStream(f));
             OutputStream out = res.getOutputStream()) {
            byte[] buf = new byte[8192];
            int read;
            while ((read = in.read(buf)) != -1) out.write(buf, 0, read);
        }
    }

    /* ── helper ─────────────────────────────────────────── */
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
