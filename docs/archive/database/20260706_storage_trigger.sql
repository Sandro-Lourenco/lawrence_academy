-- ==========================================
-- Lawrence Academy Storage Trigger & Buckets
-- Date: 2026-07-06
-- Purpose: Setup storage buckets and automated enqueuing trigger
-- ==========================================

-- 1. Assegurar a criação dos buckets de armazenamento
INSERT INTO storage.buckets (id, name, public) 
VALUES ('raw-videos', 'raw-videos', false) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO storage.buckets (id, name, public) 
VALUES ('lessons-hls', 'lessons-hls', true) 
ON CONFLICT (id) DO NOTHING;

-- 2. Função de disparo ao carregar arquivos no Storage
CREATE OR REPLACE FUNCTION public.handle_storage_video_upload()
RETURNS TRIGGER AS $$
DECLARE
    v_lesson_id UUID;
    v_filename TEXT;
BEGIN
    -- Verificar se o upload ocorreu no bucket 'raw-videos'
    IF NEW.bucket_id = 'raw-videos' THEN
        -- Obter o nome do arquivo a partir do caminho completo (ex: lessons/8f7d8b9a-1234-4bc1-9a8b-123456789abc.mp4)
        v_filename := regexp_replace(NEW.name, '^.*/', ''); -- pega apenas o final do caminho
        v_filename := regexp_replace(v_filename, '\.[^.]*$', ''); -- remove extensão
        
        -- Validar se o nome do arquivo é um UUID válido correspondente a uma lição existente
        IF v_filename ~ '^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$' THEN
            v_lesson_id := v_filename::uuid;
            
            -- Verificar se a lição existe no banco de dados para evitar FK violation
            IF EXISTS (SELECT 1 FROM public.lessons WHERE id = v_lesson_id) THEN
                -- Inserir o job na fila de processamento
                INSERT INTO public.video_processing_jobs (lesson_id, raw_video_path, status)
                VALUES (v_lesson_id, NEW.name, 'pending');
            END IF;
        END IF;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 3. Trigger na tabela storage.objects do Supabase
DROP TRIGGER IF EXISTS on_storage_video_uploaded ON storage.objects;
CREATE TRIGGER on_storage_video_uploaded
    AFTER INSERT ON storage.objects
    FOR EACH ROW EXECUTE FUNCTION public.handle_storage_video_upload();
