-- 1. SELECT 정책 최적화
DROP POLICY IF EXISTS "Users can view own profile" ON public.profiles;

CREATE POLICY "Users can view own profile" ON public.profiles FOR
SELECT
    USING (
        (
            SELECT
                auth.uid ()
        ) = id
    );

-- 2. INSERT 정책 최적화
DROP POLICY IF EXISTS "Users can insert own profile" ON public.profiles;

CREATE POLICY "Users can insert own profile" ON public.profiles FOR INSERT
WITH
    CHECK (
        (
            SELECT
                auth.uid ()
        ) = id
    );

-- 3. UPDATE 정책 최적화
DROP POLICY IF EXISTS "Users can update own profile" ON public.profiles;

CREATE POLICY "Users can update own profile" ON public.profiles FOR
UPDATE USING (
    (
        SELECT
            auth.uid ()
    ) = id
)
WITH
    CHECK (
        (
            SELECT
                auth.uid ()
        ) = id
    );