package com.miportafolio.controller;

import com.miportafolio.dao.ArchivoDAO;
import com.miportafolio.model.Archivo;
import com.miportafolio.model.Usuario;
import com.miportafolio.service.StorageService;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import jakarta.servlet.http.Part;

import java.io.IOException;
import java.nio.file.Paths;

/**
 * SubirArchivoServlet — sube un archivo al portafolio.
 *
 * POST /archivos/subir  (o /clases/crear para compat.)
 *
 * Solo la Alumna Titular (esAdmin) puede subir archivos.
 * El archivo se guarda en <contexto>/uploads/ y se registra en BD.
 */
@WebServlet(name = "SubirArchivoServlet",
            urlPatterns = {"/archivos/subir", "/clases/crear"})
@MultipartConfig(
    fileSizeThreshold = 1024 * 1024 * 2,   // 2 MB en memoria
    maxFileSize       = 1024 * 1024 * 50,  // 50 MB por archivo
    maxRequestSize    = 1024 * 1024 * 60   // 60 MB total
)
public class SubirArchivoServlet extends HttpServlet {

    private final ArchivoDAO archivoDAO = new ArchivoDAO();

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

        // ── Leer parámetros ──────────────────────────────
        String semanaStr   = req.getParameter("semana");
        String titulo      = req.getParameter("titulo");
        String descripcion = req.getParameter("descripcion");
        String tipo        = req.getParameter("tipo");

        // Extraer número de semana (acepta "1", "Semana 1", etc.)
        int semana = 1;
        if (semanaStr != null) {
            String digits = semanaStr.replaceAll("[^0-9]", "");
            if (!digits.isEmpty()) {
                semana = Math.max(1, Math.min(16, Integer.parseInt(digits)));
            }
        }
        if (tipo  == null || tipo.isBlank())  tipo  = "MATERIAL";
        if (titulo == null || titulo.isBlank()) titulo = "Sin título";

        // ── Guardar fichero en disco ─────────────────────
        Part filePart = req.getPart("archivo");
        String nombreOriginal = "";
        String nombreServidor = "";

        if (filePart != null && filePart.getSize() > 0) {
            nombreOriginal = Paths.get(
                    filePart.getSubmittedFileName()).getFileName().toString();

            String uploadDir = getServletContext().getRealPath("/uploads");
            StorageService storage = new StorageService(uploadDir);
            nombreServidor = storage.guardar(
                    filePart.getInputStream(), nombreOriginal);
        }

        // ── Registrar en BD ──────────────────────────────
        Archivo archivo = new Archivo(
                titulo.trim(),
                descripcion != null ? descripcion.trim() : "",
                nombreOriginal,
                nombreServidor,
                tipo,
                semana,
                usuario.getId()
        );
        archivoDAO.guardar(archivo);

        res.sendRedirect(req.getContextPath()
                + "/portafolio?tab=archivos&msg=upload_ok");
    }
}
