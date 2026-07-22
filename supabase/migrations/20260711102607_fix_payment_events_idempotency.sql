-- 1. Remover duplicados mantendo apenas o registro mais recente por provider_event_id
WITH duplicates AS (
    SELECT id, 
           ROW_NUMBER() OVER(
               PARTITION BY provider, provider_event_id 
               ORDER BY created_at DESC
           ) as rn
    FROM public.payment_events
)
DELETE FROM public.payment_events
WHERE id IN (SELECT id FROM duplicates WHERE rn > 1);

-- 2. Garantir que a constraint UNIQUE existe e é aplicada
-- A constraint 'uniq_provider_event' já foi definida na migration anterior, mas recriamos para segurança
ALTER TABLE public.payment_events DROP CONSTRAINT IF EXISTS uniq_provider_event;
ALTER TABLE public.payment_events ADD CONSTRAINT uniq_provider_event UNIQUE(provider, provider_event_id);
