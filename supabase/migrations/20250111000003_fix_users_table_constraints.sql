-- Remove ALL NOT NULL constraints from fields that are set during onboarding
-- Authentication should only require email and password (handled by auth.users)
-- All other fields in public.users should be nullable until onboarding is complete

DO $$
BEGIN
    -- Remove NOT NULL from name (optional at signup, can be set later)
    IF EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_schema = 'public' 
        AND table_name = 'users' 
        AND column_name = 'name'
        AND is_nullable = 'NO'
    ) THEN
        ALTER TABLE public.users ALTER COLUMN name DROP NOT NULL;
    END IF;

    -- Remove NOT NULL from age (set during onboarding)
    IF EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_schema = 'public' 
        AND table_name = 'users' 
        AND column_name = 'age'
        AND is_nullable = 'NO'
    ) THEN
        ALTER TABLE public.users ALTER COLUMN age DROP NOT NULL;
    END IF;

    -- Remove NOT NULL from gender (set during onboarding)
    IF EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_schema = 'public' 
        AND table_name = 'users' 
        AND column_name = 'gender'
        AND is_nullable = 'NO'
    ) THEN
        ALTER TABLE public.users ALTER COLUMN gender DROP NOT NULL;
    END IF;

    -- Remove NOT NULL from height (set during onboarding)
    IF EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_schema = 'public' 
        AND table_name = 'users' 
        AND column_name = 'height'
        AND is_nullable = 'NO'
    ) THEN
        ALTER TABLE public.users ALTER COLUMN height DROP NOT NULL;
    END IF;

    -- Remove NOT NULL from weight (set during onboarding)
    IF EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_schema = 'public' 
        AND table_name = 'users' 
        AND column_name = 'weight'
        AND is_nullable = 'NO'
    ) THEN
        ALTER TABLE public.users ALTER COLUMN weight DROP NOT NULL;
    END IF;

    -- Remove NOT NULL from goal (set during onboarding)
    IF EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_schema = 'public' 
        AND table_name = 'users' 
        AND column_name = 'goal'
        AND is_nullable = 'NO'
    ) THEN
        ALTER TABLE public.users ALTER COLUMN goal DROP NOT NULL;
    END IF;

    -- Remove NOT NULL from eating_pattern (set during wellness snapshot)
    IF EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_schema = 'public' 
        AND table_name = 'users' 
        AND column_name = 'eating_pattern'
        AND is_nullable = 'NO'
    ) THEN
        ALTER TABLE public.users ALTER COLUMN eating_pattern DROP NOT NULL;
    END IF;

    -- Remove NOT NULL from body_type (set during wellness snapshot)
    IF EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_schema = 'public' 
        AND table_name = 'users' 
        AND column_name = 'body_type'
        AND is_nullable = 'NO'
    ) THEN
        ALTER TABLE public.users ALTER COLUMN body_type DROP NOT NULL;
    END IF;

    -- Remove NOT NULL from metabolism (set during wellness snapshot)
    IF EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_schema = 'public' 
        AND table_name = 'users' 
        AND column_name = 'metabolism'
        AND is_nullable = 'NO'
    ) THEN
        ALTER TABLE public.users ALTER COLUMN metabolism DROP NOT NULL;
    END IF;
END $$;
