package com.miportafolio.model;

/**
 * Representa un usuario del sistema.
 * rolId = 1 → Alumna Titular (Admin)
 * rolId = 2 → Visitante / Auditor
 */
public class Usuario {

    private Integer id;
    private String  codigo;
    private String  nombre;
    private String  correo;
    private Integer rolId;   // 1=ADMIN, 2=ESTUDIANTE

    /* ── Constructores ─────────────────────────────────── */

    public Usuario() {}

    /** Constructor completo (desde BD) */
    public Usuario(Integer id, String codigo,
                   String nombre, String correo, Integer rolId) {
        this.id     = id;
        this.codigo = codigo;
        this.nombre = nombre;
        this.correo = correo;
        this.rolId  = rolId;
    }

    /** Constructor para insertar nuevo usuario */
    public Usuario(String codigo, String nombre,
                   String correo, Integer rolId) {
        this.codigo = codigo;
        this.nombre = nombre;
        this.correo = correo;
        this.rolId  = rolId;
    }

    /* ── Getters / Setters ─────────────────────────────── */

    public Integer getId()                  { return id; }
    public void    setId(Integer id)        { this.id = id; }

    public String  getCodigo()              { return codigo; }
    public void    setCodigo(String c)      { this.codigo = c; }

    public String  getNombre()              { return nombre; }
    public void    setNombre(String n)      { this.nombre = n; }

    public String  getCorreo()              { return correo; }
    public void    setCorreo(String e)      { this.correo = e; }

    public Integer getRolId()               { return rolId; }
    public void    setRolId(Integer r)      { this.rolId = r; }

    /** true si es Alumna Titular (rolId == 1 o código empieza con ADMIN) */
    public boolean esAdmin() {
        return (rolId != null && rolId == 1)
               || (codigo != null && codigo.toUpperCase().startsWith("ADMIN"));
    }
}
