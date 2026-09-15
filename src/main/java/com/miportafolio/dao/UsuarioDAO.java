package com.miportafolio.dao;

import com.miportafolio.config.DatabaseConfig;
import com.miportafolio.model.Usuario;

import java.sql.*;

/**
 * Acceso a datos para la tabla 'usuarios'.
 *
 *   id       INT AUTO_INCREMENT PRIMARY KEY
 *   codigo   VARCHAR(60) UNIQUE
 *   nombre   VARCHAR(150)
 *   correo   VARCHAR(150)
 *   rol_id   INT  (1=ADMIN, 2=ESTUDIANTE)
 */
public class UsuarioDAO {

    /* ── BUSCAR POR CÓDIGO ──────────────────────────────── */

    public Usuario buscarPorCodigo(String codigo) {
        String sql = "SELECT * FROM usuarios WHERE codigo = ?";

        try (Connection con = DatabaseConfig.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, codigo.trim().toUpperCase());
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return mapRow(rs);
            }

        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    /* ── REGISTRAR ──────────────────────────────────────── */

    public boolean registrar(Usuario usuario) {
        String sql = """
            INSERT INTO usuarios (codigo, nombre, correo, rol_id)
            VALUES (?, ?, ?, ?)
            """;

        try (Connection con = DatabaseConfig.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, usuario.getCodigo().trim().toUpperCase());
            ps.setString(2, usuario.getNombre());
            ps.setString(3, usuario.getCorreo() != null ? usuario.getCorreo() : "");
            ps.setInt   (4, usuario.getRolId()  != null ? usuario.getRolId()  : 2);

            return ps.executeUpdate() > 0;

        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    /* ── ACTUALIZAR NOMBRE ──────────────────────────────── */

    public boolean actualizarNombre(int id, String nombre) {
        String sql = "UPDATE usuarios SET nombre = ? WHERE id = ?";

        try (Connection con = DatabaseConfig.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, nombre);
            ps.setInt   (2, id);
            return ps.executeUpdate() > 0;

        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    private Usuario mapRow(ResultSet rs) throws SQLException {
        // Compatibilidad: tabla vieja usa "rol" (texto), nueva usa "rol_id" (int)
        int rolId = 2;
        try {
            rolId = rs.getInt("rol_id");
            if (rs.wasNull()) rolId = 2;
        } catch (SQLException ignored) {
            try {
                String rol = rs.getString("rol");
                rolId = ("ADMIN".equalsIgnoreCase(rol) || "1".equals(rol)) ? 1 : 2;
            } catch (SQLException ignored2) {
                rolId = 2;
            }
        }
        return new Usuario(
            rs.getInt   ("id"),
            rs.getString("codigo"),
            rs.getString("nombre"),
            safeGetString(rs, "correo"),
            rolId
        );
    }

    private String safeGetString(ResultSet rs, String col) {
        try { return rs.getString(col); }
        catch (SQLException e) { return ""; }
    }
}
