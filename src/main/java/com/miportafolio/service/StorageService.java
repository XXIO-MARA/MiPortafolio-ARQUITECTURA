package com.miportafolio.service;

import java.io.File;
import java.io.IOException;
import java.io.InputStream;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.StandardCopyOption;
import java.util.UUID;

/**
 * StorageService — capa de servicio para gestión de archivos físicos.
 *
 * Centraliza toda la lógica de almacenamiento en disco para que los
 * servlets no tengan que manejar rutas ni UUIDs directamente.
 *
 * Directorio base: <contexto_web>/uploads/
 */
public class StorageService {

    private final String uploadDir;

    public StorageService(String uploadDir) {
        this.uploadDir = uploadDir;
        // Asegurar que el directorio exista
        File dir = new File(uploadDir);
        if (!dir.exists()) dir.mkdirs();
    }

    /* ── GUARDAR ARCHIVO ────────────────────────────────── */

    /**
     * Guarda el fichero en Supabase Storage (permanente en la nube).
     * Si no está disponible, lo guarda en el disco local como respaldo.
     *
     * @param inputStream   Datos del fichero
     * @param originalName  Nombre original (para conservar extensión)
     * @return              URL pública de Supabase o nombre generado en servidor
     * @throws IOException  Si hay error al escribir
     */
    public String guardar(InputStream inputStream, String originalName)
            throws IOException {
        String cleanName = originalName != null ? originalName.replaceAll("[^a-zA-Z0-9._-]", "_") : "archivo";
        String serverName = UUID.randomUUID() + "_" + cleanName;

        byte[] bytes = inputStream.readAllBytes();

        // 1. Intentar subir a Supabase Storage (nube permanente)
        if (com.miportafolio.config.SupabaseConfig.isConfigured()) {
            try {
                String supabaseUrl = subirASupabase(bytes, serverName);
                if (supabaseUrl != null && !supabaseUrl.isBlank()) {
                    System.out.println("[STORAGE] Archivo subido exitosamente a Supabase: " + supabaseUrl);
                    return supabaseUrl;
                }
            } catch (Exception e) {
                System.err.println("[STORAGE] Error al subir a Supabase (" + e.getMessage() + "), guardando en disco local.");
            }
        }

        // 2. Fallback: guardar en disco local
        Path destino = Path.of(uploadDir, serverName);
        Files.write(destino, bytes);
        return serverName;
    }

    private String subirASupabase(byte[] bytes, String serverName) {
        try {
            String baseUrl = com.miportafolio.config.SupabaseConfig.getUrl();
            String bucket = com.miportafolio.config.SupabaseConfig.getBucket();
            String anonKey = com.miportafolio.config.SupabaseConfig.getAnonKey();

            String uploadEndpoint = baseUrl + "/storage/v1/object/" + bucket + "/" + serverName;

            java.net.http.HttpClient client = java.net.http.HttpClient.newHttpClient();
            java.net.http.HttpRequest request = java.net.http.HttpRequest.newBuilder()
                    .uri(java.net.URI.create(uploadEndpoint))
                    .header("Authorization", "Bearer " + anonKey)
                    .header("apikey", anonKey)
                    .header("Content-Type", "application/octet-stream")
                    .POST(java.net.http.HttpRequest.BodyPublishers.ofByteArray(bytes))
                    .build();

            java.net.http.HttpResponse<String> response = client.send(request,
                    java.net.http.HttpResponse.BodyHandlers.ofString());

            if (response.statusCode() == 200 || response.statusCode() == 201) {
                return baseUrl + "/storage/v1/object/public/" + bucket + "/" + serverName;
            } else {
                System.err.println("[STORAGE] Supabase respondió con código " + response.statusCode() + ": " + response.body());
            }
        } catch (Exception e) {
            System.err.println("[STORAGE] Fallo HTTP en Supabase: " + e.getMessage());
        }
        return null;
    }

    /* ── ELIMINAR ARCHIVO ───────────────────────────────── */

    /**
     * Elimina el fichero físico del disco o de Supabase.
     *
     * @param serverName  URL de Supabase o nombre en servidor
     * @return            true si se eliminó, false si no existía
     */
    public boolean eliminar(String serverName) {
        if (serverName == null || serverName.isBlank()) return false;
        if (serverName.startsWith("http")) {
            try {
                String filename = serverName.substring(serverName.lastIndexOf('/') + 1);
                String baseUrl = com.miportafolio.config.SupabaseConfig.getUrl();
                String bucket = com.miportafolio.config.SupabaseConfig.getBucket();
                String anonKey = com.miportafolio.config.SupabaseConfig.getAnonKey();

                String deleteEndpoint = baseUrl + "/storage/v1/object/" + bucket + "/" + filename;
                java.net.http.HttpClient client = java.net.http.HttpClient.newHttpClient();
                java.net.http.HttpRequest request = java.net.http.HttpRequest.newBuilder()
                        .uri(java.net.URI.create(deleteEndpoint))
                        .header("Authorization", "Bearer " + anonKey)
                        .header("apikey", anonKey)
                        .DELETE()
                        .build();
                client.send(request, java.net.http.HttpResponse.BodyHandlers.discarding());
                return true;
            } catch (Exception ignored) {}
        }
        File file = new File(uploadDir, serverName);
        return file.exists() && file.delete();
    }

    /* ── OBTENER RUTA COMPLETA ──────────────────────────── */

    /**
     * Devuelve el File del servidor para un nombre dado.
     *
     * @param serverName  Nombre en servidor
     * @return            File apuntando a la ruta completa
     */
    public File getFile(String serverName) {
        return new File(uploadDir, serverName);
    }

    /* ── VERIFICAR EXISTENCIA ───────────────────────────── */

    public boolean existe(String serverName) {
        return serverName != null && new File(uploadDir, serverName).exists();
    }
}
