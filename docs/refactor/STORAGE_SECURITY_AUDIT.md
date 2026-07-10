# Relatório de Auditoria: Segurança do Supabase Storage

**Status:** Concluído  
**Data:** 10 de Julho de 2026  
**Auditor:** Principal Software Architect / Security Engineer  

---

## 1. Contexto e Objetivo
Esta auditoria analisa as configurações e políticas de segurança dos buckets do Supabase Storage na Lawrence Academy, com o objetivo de assegurar a proteção de propriedade intelectual (vídeos de aulas) contra downloads não autorizados, pirataria ou vazamentos.

---

## 2. Configuração de Buckets do Storage

O Lawrence Academy utiliza dois buckets principais no Supabase Storage:

1. **`raw-videos` (Privado):**
   - **Propósito:** Armazenamento temporário dos vídeos crus (MP4) enviados pelos professores antes do processamento e conversão.
   - **Configuração de Privacidade:** `public = false`.
   - **Segurança:** Acesso direto público bloqueado. Downloads permitidos apenas via Service Role ou usuários docentes/administradores autorizados.
2. **`lessons-hls` (Privado):**
   - **Propósito:** Armazenamento dos arquivos segmentados do protocolo HTTP Live Streaming (HLS), contendo o arquivo de manifesto `.m3u8` e os blocos de vídeo `.ts`.
   - **Configuração de Privacidade:** `public = false` (Atualizado nesta fase, anteriormente configurado incorretamente como `public = true`).
   - **Segurança:** O bloqueio público previne que um usuário mal-intencionado varra o bucket decifrando IDs de lições para obter acesso gratuito aos vídeos.

---

## 3. Fluxo de Acesso e Streaming Seguro
Como ambos os buckets estão definidos como **estritamente privados (`public = false`)** e não possuem políticas públicas de leitura (`SELECT`) em `storage.objects`:

1. **Geração de URLs Assinadas:** Quando um estudante autorizado requisita a aula, o endpoint `/api/courses/{id}/lessons/{lesson_id}/stream` no backend FastAPI valida a assinatura ativa do estudante para aquele curso específico.
2. **Token Temporário:** Sendo o estudante autorizado, o backend utiliza a instância `supabase_admin` (com chave `service_role`) para assinar uma URL de download temporária que expira em 3600 segundos (1 hora).
3. **Player HLS:** O player de vídeo Flutter consome a URL assinada temporária para fazer o download sob demanda dos segmentos HLS de forma segura, garantindo proteção contra pirataria e downloads em lote.

---

## 4. Integração Automatizada (Triggers)
A tabela `storage.objects` possui um trigger automático `on_storage_video_uploaded` que dispara a função `public.handle_storage_video_upload()`.
- **Ação:** Identifica novos uploads no bucket `raw-videos`. Caso o nome do arquivo corresponda a um UUID de aula existente no banco de dados, cria um job pendente na tabela `video_processing_jobs` para iniciar a conversão assíncrona para HLS.
- **Segurança:** A função de disparo roda com `SECURITY DEFINER`, permitindo escrita segura na tabela de jobs de processamento sem expor privilégios de gravação para o cliente que executou o upload.
