-- Crea la base de datos dedicada para los datos restaurados desde Supabase.
-- La base 'n8n' (definida por POSTGRES_DB) queda reservada para las tablas
-- internas de n8n. Los datos de tu proyecto (documentos, chunks, embeddings,
-- historial de chat y funciones match_*) viven en la base 'aura'.
CREATE DATABASE aura;
