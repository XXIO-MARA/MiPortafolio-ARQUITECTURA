package com.miportafolio.dao;

import com.miportafolio.config.DatabaseConfig;
import com.miportafolio.model.Archivo;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

/**
 * Acceso a datos para la tabla 'archivos'.
 *
 * La tabla tiene la siguiente estructura MySQL:
 *
 *   id            INT AUTO_INCREMENT PRIMARY KEY
 *   titulo        VARCHAR(150)
 *   descripcion   TEXT
 *   nombre_archivo VARCHAR(255)   -- nombre original del fichero
 *   url_archivo   VARCHAR(500)    -- nombre en disco (UUID_xxx)
 *   tipo          VARCHAR(50)     -- MATERIAL | TAREA
 *   semana        INT
 *   fecha         TIMESTAMP DEFAULT CURRENT_TIMESTAMP
 *   usuario_id    INT (FK nullable)
 */
public class ArchivoDAO {

    /* ── GUARDAR ────────────────────────────────────────── */

    public boolean guardar(Archivo archivo) {
        String sql = """
            INSERT INTO archivos
              (titulo, descripcion, nombre_archivo,
               url_archivo, tipo, semana, usuario_id)
            VALUES (?, ?, ?, ?, ?, ?, ?)
            """;

        try (Connection con = DatabaseConfig.getConnection();
             PreparedStatement ps = con.prepareStatement(
                     sql, Statement.RETURN_GENERATED_KEYS)) {

            ps.setString(1, archivo.getTitulo());
            ps.setString(2, archivo.getDescripcion());
            ps.setString(3, archivo.getNombreArchivo());
            ps.setString(4, archivo.getUrlArchivo());
            ps.setString(5, archivo.getTipo());
            ps.setInt   (6, archivo.getSemana());

            if (archivo.getUsuarioId() != null) {
                ps.setInt(7, archivo.getUsuarioId());
            } else {
                ps.setNull(7, Types.INTEGER);
            }

            int rows = ps.executeUpdate();

            try (ResultSet keys = ps.getGeneratedKeys()) {
                if (keys.next()) archivo.setId(keys.getInt(1));
            }

            return rows > 0;

        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    /* ── LISTAR TODOS ───────────────────────────────────── */

    public List<Archivo> listar() {
        List<Archivo> lista = new ArrayList<>();
        String sql = "SELECT * FROM archivos ORDER BY fecha DESC";

        try (Connection con = DatabaseConfig.getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) lista.add(mapRow(rs));

        } catch (Exception e) {
            e.printStackTrace();
        }
        return lista;
    }

    /* ── LISTAR POR SEMANA ──────────────────────────────── */

    public List<Archivo> listarPorSemana(int semana) {
        List<Archivo> lista = new ArrayList<>();
        String sql = "SELECT * FROM archivos WHERE semana = ? ORDER BY fecha DESC";

        try (Connection con = DatabaseConfig.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, semana);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) lista.add(mapRow(rs));
            }

        } catch (Exception e) {
            e.printStackTrace();
        }
        return lista;
    }

    /* ── BUSCAR POR ID ──────────────────────────────────── */

    public Archivo buscarPorId(int id) {
        String sql = "SELECT * FROM archivos WHERE id = ?";

        try (Connection con = DatabaseConfig.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return mapRow(rs);
            }

        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    /* ── ELIMINAR ───────────────────────────────────────── */

    public boolean eliminar(int id) {
        String sql = "DELETE FROM archivos WHERE id = ?";

        try (Connection con = DatabaseConfig.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, id);
            return ps.executeUpdate() > 0;

        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    /* ── MAPPER ─────────────────────────────────────────── */

    private Archivo mapRow(ResultSet rs) throws SQLException {
        Archivo a = new Archivo();
        a.setId           (rs.getInt       ("id"));
        a.setTitulo       (rs.getString    ("titulo"));
        a.setDescripcion  (rs.getString    ("descripcion"));
        a.setNombreArchivo(rs.getString    ("nombre_archivo"));
        a.setUrlArchivo   (rs.getString    ("url_archivo"));
        a.setTipo         (rs.getString    ("tipo"));
        a.setSemana       (rs.getInt       ("semana"));
        a.setFecha        (rs.getTimestamp ("fecha"));

        int uid = rs.getInt("usuario_id");
        if (!rs.wasNull()) a.setUsuarioId(uid);

        return a;
    }
}
