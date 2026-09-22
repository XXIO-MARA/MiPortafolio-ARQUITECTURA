package com.miportafolio.service;

import com.miportafolio.dao.UsuarioDAO;
import com.miportafolio.model.Usuario;

/**
 * AuthService — capa de servicio para autenticación.
 *
 * Encapsula la lógica de login y registro para que los servlets
 * no dependan directamente del DAO.
 */
public class AuthService {

    private final UsuarioDAO usuarioDAO = new UsuarioDAO();

    /* ── LOGIN ──────────────────────────────────────────── */

    /**
     * Busca el usuario por código (sin importar mayúsculas/minúsculas).
     * Devuelve null si no existe.
     */
    public Usuario login(String codigo) {
        if (codigo == null || codigo.isBlank()) return null;
        return usuarioDAO.buscarPorCodigo(codigo.trim().toUpperCase());
    }

    /* ── REGISTRO ───────────────────────────────────────── */

    /**
     * Registra un nuevo usuario con rol de visitante (rolId=2).
     * Devuelve false si el código ya existe o los datos son inválidos.
     */
    public boolean registrar(String codigo, String nombre) {
        if (codigo == null || codigo.isBlank()) return false;
        if (nombre  == null || nombre.isBlank())  return false;
        if (usuarioDAO.buscarPorCodigo(codigo.trim().toUpperCase()) != null) return false;

        Usuario u = new Usuario(
                codigo.trim().toUpperCase(),
                nombre.trim(),
                "",
                2
        );
        return usuarioDAO.registrar(u);
    }

    /**
     * Versión con correo opcional.
     */
    public boolean registrar(String codigo, String nombre, String correo) {
        if (codigo == null || codigo.isBlank()) return false;
        if (nombre  == null || nombre.isBlank())  return false;
        if (usuarioDAO.buscarPorCodigo(codigo.trim().toUpperCase()) != null) return false;

        Usuario u = new Usuario(
                codigo.trim().toUpperCase(),
                nombre.trim(),
                correo != null ? correo.trim() : "",
                2
        );
        return usuarioDAO.registrar(u);
    }
}
