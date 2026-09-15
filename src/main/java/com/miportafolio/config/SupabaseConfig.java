package com.miportafolio.config;

/**
 * SupabaseConfig — configuración y constantes para Supabase Storage.
 * Permite almacenamiento permanente de archivos en la nube sin depender
 * del sistema de archivos efímero de Render.
 */
public class SupabaseConfig {

    private static final String DEFAULT_URL      = "https://fptdsrniauplvzrwqezm.supabase.co";
    private static final String DEFAULT_ANON_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImZwdGRzcm5pYXVwbHZ6cndxZXptIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODkyNjMxMjMsImV4cCI6MjEwNDgzOTEyM30.Shu-lV32YRDzXrHXen2lhBrLfrLiBBNZIza8FJ1Zx0I";
    private static final String DEFAULT_BUCKET   = "portafolio-upla";

    private SupabaseConfig() {}

    /** URL base de Supabase */
    public static String getUrl() {
        String env = System.getenv("SUPABASE_URL");
        if (env != null && !env.isBlank()) return cleanUrl(env);
        String prop = System.getProperty("supabase.url");
        if (prop != null && !prop.isBlank()) return cleanUrl(prop);
        return DEFAULT_URL;
    }

    /** Clave pública anónima de Supabase */
    public static String getAnonKey() {
        String env = System.getenv("SUPABASE_ANON_KEY");
        if (env != null && !env.isBlank()) return env.trim();
        String prop = System.getProperty("supabase.anon_key");
        if (prop != null && !prop.isBlank()) return prop.trim();
        return DEFAULT_ANON_KEY;
    }

    /** Nombre del bucket público */
    public static String getBucket() {
        String env = System.getenv("SUPABASE_BUCKET");
        if (env != null && !env.isBlank()) return env.trim();
        String prop = System.getProperty("supabase.bucket");
        if (prop != null && !prop.isBlank()) return prop.trim();
        return DEFAULT_BUCKET;
    }

    /** true si Supabase está configurado */
    public static boolean isConfigured() {
        return !getUrl().isEmpty() && !getAnonKey().isEmpty();
    }

    private static String cleanUrl(String url) {
        String clean = url.trim();
        if (clean.endsWith("/rest/v1/")) {
            clean = clean.substring(0, clean.length() - 9);
        } else if (clean.endsWith("/rest/v1")) {
            clean = clean.substring(0, clean.length() - 8);
        }
        if (clean.endsWith("/")) {
            clean = clean.substring(0, clean.length() - 1);
        }
        return clean;
    }
}
