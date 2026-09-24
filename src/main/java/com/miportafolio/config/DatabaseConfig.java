package com.miportafolio.config;

import com.zaxxer.hikari.HikariConfig;
import com.zaxxer.hikari.HikariDataSource;

import java.io.InputStream;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.Properties;

/**
 * Configuración del pool HikariCP → MySQL.
 *
 * Se inicializa en el primer uso (lazy) o explícitamente desde un
 * ServletContextListener. Crea las tablas y los usuarios iniciales
 * si no existen.
 */
public class DatabaseConfig {

    private static HikariDataSource dataSource;

    private DatabaseConfig() {}

    /* ── INICIALIZAR POOL ───────────────────────────────── */

    public static synchronized void init() {
        if (dataSource != null) return;

        try {
            Properties props = new Properties();
            InputStream in = DatabaseConfig.class
                    .getClassLoader()
                    .getResourceAsStream("application.properties");

            if (in == null)
                throw new IllegalStateException("No se encontró application.properties");

            props.load(in);

            HikariConfig cfg = new HikariConfig();

            // Soporte para Render / Nube (Variables de entorno) con fallback a application.properties
            String jdbcUrl = System.getenv("DB_URL");
            if (jdbcUrl == null || jdbcUrl.isBlank()) jdbcUrl = System.getenv("DATABASE_URL");
            if (jdbcUrl == null || jdbcUrl.isBlank()) jdbcUrl = System.getenv("MYSQL_URL");
            if (jdbcUrl == null || jdbcUrl.isBlank()) jdbcUrl = props.getProperty("db.url");

            if (jdbcUrl != null && jdbcUrl.startsWith("mysql://")) {
                jdbcUrl = "jdbc:" + jdbcUrl;
            }

            String username = System.getenv("DB_USER");
            if (username == null || username.isBlank()) username = System.getenv("DB_USERNAME");
            if (username == null || username.isBlank()) username = props.getProperty("db.username");

            String password = System.getenv("DB_PASSWORD");
            if (password == null) password = System.getenv("DB_PASS");
            if (password == null) password = props.getProperty("db.password");

            cfg.setJdbcUrl        (jdbcUrl);
            cfg.setUsername       (username);
            cfg.setPassword       (password);
            cfg.setDriverClassName("com.mysql.cj.jdbc.Driver");
            cfg.setMaximumPoolSize(10);
            cfg.setMinimumIdle    (2);
            cfg.setConnectionTimeout(30_000);
            cfg.setPoolName       ("PortafolioPool");

            dataSource = new HikariDataSource(cfg);
            System.out.println("[DB] Pool HikariCP iniciado correctamente.");

            crearEsquema();
            sincronizarUsuarios();
            sincronizarArchivosIniciales();

        } catch (Exception e) {
            throw new RuntimeException("Error al inicializar la base de datos", e);
        }
    }

    /* ── OBTENER CONEXIÓN ───────────────────────────────── */

    public static Connection getConnection() throws SQLException {
        if (dataSource == null) init();
        return dataSource.getConnection();
    }

    /* ── CERRAR POOL ────────────────────────────────────── */

    public static synchronized void close() {
        if (dataSource != null && !dataSource.isClosed()) {
            dataSource.close();
            System.out.println("[DB] Pool cerrado.");
        }
    }

    /* ── CREAR ESQUEMA ──────────────────────────────────── */

    private static void crearEsquema() throws SQLException {
        try (Connection con = dataSource.getConnection();
             Statement  st  = con.createStatement()) {

            // ── usuarios ──────────────────────────────────
            st.execute("""
                CREATE TABLE IF NOT EXISTS usuarios (
                    id       INT AUTO_INCREMENT PRIMARY KEY,
                    codigo   VARCHAR(60)  NOT NULL UNIQUE,
                    nombre   VARCHAR(150) NOT NULL,
                    correo   VARCHAR(150) NOT NULL DEFAULT '',
                    rol_id   INT          NOT NULL DEFAULT 2
                )
                """);

            // ── Migración: agregar columnas si la tabla ya existía sin ellas ──
            // correo
            try {
                st.execute("""
                    ALTER TABLE usuarios
                    ADD COLUMN correo VARCHAR(150) NOT NULL DEFAULT ''
                    """);
                System.out.println("[DB] Columna 'correo' agregada a usuarios.");
            } catch (Exception ignored) {
                // Ya existe — no hacer nada
            }

            // rol_id (por si vino de versión con columna 'rol' texto)
            try {
                st.execute("""
                    ALTER TABLE usuarios
                    ADD COLUMN rol_id INT NOT NULL DEFAULT 2
                    """);
                System.out.println("[DB] Columna 'rol_id' agregada a usuarios.");
            } catch (Exception ignored) {
                // Ya existe — no hacer nada
            }

            // ── archivos (tabla principal del portafolio) ─
            st.execute("""
                CREATE TABLE IF NOT EXISTS archivos (
                    id             INT AUTO_INCREMENT PRIMARY KEY,
                    titulo         VARCHAR(150)  NOT NULL,
                    descripcion    TEXT,
                    nombre_archivo VARCHAR(255),
                    url_archivo    VARCHAR(500),
                    tipo           VARCHAR(50),
                    semana         INT           DEFAULT 1,
                    fecha          TIMESTAMP     DEFAULT CURRENT_TIMESTAMP,
                    usuario_id     INT,
                    FOREIGN KEY (usuario_id)
                        REFERENCES usuarios(id)
                        ON DELETE SET NULL
                )
                """);

            System.out.println("[DB] Esquema verificado/creado.");
        }
    }

    /* ── DATOS INICIALES ────────────────────────────────── */

    private static void sincronizarUsuarios() throws SQLException {
        // Usar UPDATE separado en lugar de upsert para mayor compatibilidad
        // con tablas que venían de versiones anteriores del proyecto
        try (Connection con = dataSource.getConnection()) {

            // ── Alumna Titular (ADMIN) ─────────────────────
            asegurarUsuario(con,
                "ADMIN949163067",
                "Flor Xiomara Medina Salazar",
                "s01269h@upla.edu.pe",
                1);

            // ── Visitante / Auditor ────────────────────────
            asegurarUsuario(con,
                "EST2026",
                "Visitante Académico / Auditor UPLA",
                "auditor@upla.edu.pe",
                2);

            System.out.println("[DB] Usuarios iniciales sincronizados.");
        }
    }

    /** Inserta el usuario si no existe, o actualiza si ya existe. */
    private static void asegurarUsuario(Connection con,
                                        String codigo,
                                        String nombre,
                                        String correo,
                                        int rolId) throws SQLException {
        // ¿Ya existe?
        try (PreparedStatement chk = con.prepareStatement(
                "SELECT id FROM usuarios WHERE codigo = ?")) {
            chk.setString(1, codigo);
            try (var rs = chk.executeQuery()) {
                if (rs.next()) {
                    // Actualizar
                    try (PreparedStatement upd = con.prepareStatement(
                            "UPDATE usuarios SET nombre=?, correo=?, rol_id=? WHERE codigo=?")) {
                        upd.setString(1, nombre);
                        upd.setString(2, correo);
                        upd.setInt   (3, rolId);
                        upd.setString(4, codigo);
                        upd.executeUpdate();
                    }
                    return;
                }
            }
        }
        // Insertar
        try (PreparedStatement ins = con.prepareStatement(
                "INSERT INTO usuarios (codigo, nombre, correo, rol_id) VALUES (?,?,?,?)")) {
            ins.setString(1, codigo);
            ins.setString(2, nombre);
            ins.setString(3, correo);
            ins.setInt   (4, rolId);
            ins.executeUpdate();
        }
    }

    /* ── ARCHIVOS INICIALES (PERSISTENCIA ACADÉMICA) ────────── */

    private static void sincronizarArchivosIniciales() {
        try (Connection con = dataSource.getConnection()) {
            // Si ya existen archivos en la tabla, respetamos el estado actual (archivos eliminados o agregados)
            try (Statement st = con.createStatement();
                 ResultSet rs = st.executeQuery("SELECT COUNT(*) FROM archivos")) {
                if (rs.next() && rs.getInt(1) > 0) {
                    return;
                }
            }

            int adminId = 1;
            try (PreparedStatement ps = con.prepareStatement("SELECT id FROM usuarios WHERE codigo = 'ADMIN949163067'")) {
                try (var rs = ps.executeQuery()) {
                    if (rs.next()) adminId = rs.getInt("id");
                }
            } catch (Exception ignored) {}

            asegurarArchivo(con,
                "Presentación del curso y Sílabo de Arquitectura de Software",
                "Presentación general del curso y sílabo, donde se detallan los temas, actividades y aprendizajes que se desarrollarán durante el semestre.",
                "VIII_ArquitecturaSoftware_Silabo_REFB.pdf",
                "e9123a1a-81cb-4a6d-af4f-5c96fb02e4b1_VIII_ArquitecturaSoftware_Silabo_REFB.pdf",
                "MATERIAL",
                1,
                adminId);

            asegurarArchivo(con,
                "Introducción y Definición de la Arquitectura de Software",
                "Introducción a los conceptos fundamentales de la arquitectura de software, su importancia en el desarrollo de sistemas y los principios que permiten diseñar soluciones eficientes y de calidad.",
                "1788660294532_Sesion01_ArquitecturaSw_2026.exe",
                "4b01af0b-7c17-494b-9207-3d26a26bc38a_1788660294532_Sesion01_ArquitecturaSw_2026.exe",
                "MATERIAL",
                1,
                adminId);

            System.out.println("[DB] Archivos iniciales sincronizados correctamente.");
        } catch (Exception e) {
            System.err.println("[DB] Aviso al sincronizar archivos iniciales: " + e.getMessage());
        }
    }

    private static void asegurarArchivo(Connection con,
                                        String titulo,
                                        String descripcion,
                                        String nombreArchivo,
                                        String urlArchivo,
                                        String tipo,
                                        int semana,
                                        int usuarioId) throws SQLException {
        try (PreparedStatement chk = con.prepareStatement(
                "SELECT id FROM archivos WHERE url_archivo = ?")) {
            chk.setString(1, urlArchivo);
            try (var rs = chk.executeQuery()) {
                if (rs.next()) return; // Ya existe en BD
            }
        }

        try (PreparedStatement ins = con.prepareStatement("""
                INSERT INTO archivos (titulo, descripcion, nombre_archivo, url_archivo, tipo, semana, usuario_id)
                VALUES (?, ?, ?, ?, ?, ?, ?)
                """)) {
            ins.setString(1, titulo);
            ins.setString(2, descripcion);
            ins.setString(3, nombreArchivo);
            ins.setString(4, urlArchivo);
            ins.setString(5, tipo);
            ins.setInt   (6, semana);
            ins.setInt   (7, usuarioId);
            ins.executeUpdate();
        }
    }
}
