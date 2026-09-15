# 🌸 MiPortafolio - Arquitectura de Software EPISC UPLA 2026-I

Portafolio Académico Digital desarrollado con arquitectura **MVC Jakarta EE (Servlets 6.0 + JSP)**, base de datos relacional y diseño cósmico cyberpunk con soporte de carrusel de 16 semanas, asistente interactivo Michi y visor de documentos PDF.

- **Autora:** Flor Xiomara Medina Salazar (`s01269h@upla.edu.pe`)
- **Docente:** Mg. Raúl Enrique Fernández Bejarano (`d.rfernandezb@ms.upla.edu.pe`)
- **Carrera:** Ingeniería de Sistemas y Computación (EPISC)
- **Asignatura:** Arquitectura de Software (Código: 332181)

---

## 📁 Estructura del Proyecto

```text
MiPortafolio/
│
├── pom.xml
├── Dockerfile
├── README.md
└── .gitignore
│
└── src/
    └── main/
        │
        ├── java/
        │   └── com/
        │       └── miportafolio/
        │           │
        │           ├── config/
        │           │   ├── DatabaseConfig.java
        │           │   └── SupabaseConfig.java
        │           │
        │           ├── controller/
        │           │   ├── ArchivoServlet.java
        │           │   ├── ArchivoVisualizarServlet.java
        │           │   ├── DescargarArchivoServlet.java
        │           │   ├── EliminarArchivoServlet.java
        │           │   ├── LoginServlet.java
        │           │   ├── LogoutServlet.java
        │           │   ├── RegistroServlet.java
        │           │   ├── SubirArchivoServlet.java
        │           │   └── VisitarServlet.java
        │           │
        │           ├── dao/
        │           │   ├── ArchivoDAO.java
        │           │   └── UsuarioDAO.java
        │           │
        │           ├── model/
        │           │   ├── Archivo.java
        │           │   └── Usuario.java
        │           │
        │           └── service/
        │               ├── AuthService.java
        │               └── StorageService.java
        │
        ├── resources/
        │   └── application.properties
        │
        └── webapp/
            │
            ├── index.jsp
            ├── login.jsp
            ├── registro.jsp
            ├── dashboard.jsp
            │
            ├── css/
            ├── js/
            ├── semanas/
            ├── unidades/
            ├── videos/
            └── WEB-INF/
```
