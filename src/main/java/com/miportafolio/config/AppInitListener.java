package com.miportafolio.config;

import jakarta.servlet.ServletContextEvent;
import jakarta.servlet.ServletContextListener;
import jakarta.servlet.annotation.WebListener;

/**
 * AppInitListener — inicializa y cierra el pool de BD con el servidor.
 *
 * Se ejecuta automáticamente cuando Tomcat arranca/para la aplicación.
 * Llama a DatabaseConfig.init() que:
 *   1. Conecta al pool HikariCP → MySQL
 *   2. Crea las tablas si no existen
 *   3. Migra columnas faltantes (ALTER TABLE)
 *   4. Sincroniza los usuarios iniciales
 */
@WebListener
public class AppInitListener implements ServletContextListener {

    @Override
    public void contextInitialized(ServletContextEvent sce) {
        try {
            DatabaseConfig.init();
            System.out.println("[APP] Portafolio UPLA iniciado — BD lista.");
        } catch (Exception e) {
            System.err.println("[APP] AVISO: No se pudo conectar a la BD en el arranque: " + e.getMessage());
            System.err.println("[APP] La aplicación continuará y reintentará la conexión con la primera solicitud.");
        }
    }

    @Override
    public void contextDestroyed(ServletContextEvent sce) {
        DatabaseConfig.close();
        System.out.println("[APP] Portafolio UPLA detenido.");
    }
}
