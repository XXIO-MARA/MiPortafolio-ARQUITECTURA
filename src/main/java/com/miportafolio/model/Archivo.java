package com.miportafolio.model;

import java.sql.Timestamp;

/**
 * Modelo unificado de Archivo para el portafolio.
 *
 * Cada archivo pertenece a una semana académica y tiene:
 *  - titulo       : nombre visible del tema/tarea
 *  - descripcion  : detalle del contenido
 *  - semana       : número de semana (1-16)
 *  - tipo         : "MATERIAL" | "TAREA"
 *  - nombreArchivo: nombre original del fichero subido
 *  - urlArchivo   : nombre en servidor (UUID_original.ext)
 *  - usuarioId    : quién lo subió
 *  - fecha        : timestamp de creación
 */
public class Archivo {

    private int       id;
    private String    titulo;
    private String    descripcion;
    private String    nombreArchivo;   // nombre original visible
    private String    urlArchivo;      // nombre en disco (UUID_xxx)
    private String    tipo;            // MATERIAL | TAREA
    private int       semana;          // 1-16
    private Timestamp fecha;
    private Integer   usuarioId;

    /* ── Constructores ─────────────────────────────────── */

    public Archivo() {}

    /** Constructor completo — para leer desde BD */
    public Archivo(int id, String titulo, String descripcion,
                   String nombreArchivo, String urlArchivo,
                   String tipo, int semana,
                   Timestamp fecha, Integer usuarioId) {
        this.id            = id;
        this.titulo        = titulo;
        this.descripcion   = descripcion;
        this.nombreArchivo = nombreArchivo;
        this.urlArchivo    = urlArchivo;
        this.tipo          = tipo;
        this.semana        = semana;
        this.fecha         = fecha;
        this.usuarioId     = usuarioId;
    }

    /** Constructor para insertar nuevo archivo */
    public Archivo(String titulo, String descripcion,
                   String nombreArchivo, String urlArchivo,
                   String tipo, int semana, Integer usuarioId) {
        this.titulo        = titulo;
        this.descripcion   = descripcion;
        this.nombreArchivo = nombreArchivo;
        this.urlArchivo    = urlArchivo;
        this.tipo          = tipo;
        this.semana        = semana;
        this.usuarioId     = usuarioId;
    }

    /* ── Getters / Setters ─────────────────────────────── */

    public int       getId()                       { return id; }
    public void      setId(int id)                 { this.id = id; }

    public String    getTitulo()                   { return titulo; }
    public void      setTitulo(String t)           { this.titulo = t; }

    public String    getDescripcion()              { return descripcion; }
    public void      setDescripcion(String d)      { this.descripcion = d; }

    public String    getNombreArchivo()            { return nombreArchivo; }
    public void      setNombreArchivo(String n)    { this.nombreArchivo = n; }

    public String    getUrlArchivo()               { return urlArchivo; }
    public void      setUrlArchivo(String u)       { this.urlArchivo = u; }

    public String    getTipo()                     { return tipo; }
    public void      setTipo(String tipo)          { this.tipo = tipo; }

    public int       getSemana()                   { return semana; }
    public void      setSemana(int s)              { this.semana = s; }

    public Timestamp getFecha()                    { return fecha; }
    public void      setFecha(Timestamp f)         { this.fecha = f; }

    public Integer   getUsuarioId()                { return usuarioId; }
    public void      setUsuarioId(Integer u)       { this.usuarioId = u; }

    /* ── Helpers ───────────────────────────────────────── */

    /** true si el archivo es un PDF (para visor inline) */
    public boolean esPdf() {
        return nombreArchivo != null
               && nombreArchivo.toLowerCase().endsWith(".pdf");
    }

    /** true si el archivo es un documento Word (.docx o .doc) */
    public boolean esWord() {
        if (nombreArchivo == null) return false;
        String n = nombreArchivo.toLowerCase();
        return n.endsWith(".docx") || n.endsWith(".doc");
    }

    /** true si se puede previsualizar en el navegador (PDF, Word, Imágenes) */
    public boolean esVisualizable() {
        if (nombreArchivo == null) return false;
        String n = nombreArchivo.toLowerCase();
        return n.endsWith(".pdf") || n.endsWith(".docx") || n.endsWith(".doc")
                || n.endsWith(".png") || n.endsWith(".jpg") || n.endsWith(".jpeg");
    }

    /** true si es tipo TAREA */
    public boolean esTarea() {
        return "TAREA".equalsIgnoreCase(tipo);
    }
}
