-- Fix duplicate NIP values before adding unique constraint.
-- Append a random suffix to duplicates (keep the most recently updated row unchanged).
WITH ranked AS (
  SELECT id, nip,
         ROW_NUMBER() OVER (PARTITION BY nip ORDER BY updated_at DESC) AS rn
  FROM public.users
  WHERE nip IS NOT NULL
)
UPDATE public.users
SET nip = ranked.nip || '-' || substr(gen_random_uuid()::text, 1, 8)
FROM ranked
WHERE public.users.id = ranked.id
  AND ranked.rn > 1;

-- Add unique constraint on users.nip (partial index: only non-null values)
CREATE UNIQUE INDEX IF NOT EXISTS users_nip_unique ON public.users (nip) WHERE nip IS NOT NULL;
