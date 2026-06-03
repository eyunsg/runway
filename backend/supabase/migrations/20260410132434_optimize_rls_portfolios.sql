-- 1. SELECT 정책 최적화
DROP POLICY IF EXISTS "Users can view own portfolio" ON public.portfolios;

CREATE POLICY "Users can view own portfolio" ON public.portfolios FOR
SELECT
    USING (
        (
            SELECT
                auth.uid ()
        ) = user_id
    );

-- 2. INSERT 정책 최적화
DROP POLICY IF EXISTS "Users can insert own portfolio" ON public.portfolios;

CREATE POLICY "Users can insert own portfolio" ON public.portfolios FOR INSERT
WITH
    CHECK (
        (
            SELECT
                auth.uid ()
        ) = user_id
    );

-- 3. UPDATE 정책 최적화
DROP POLICY IF EXISTS "Users can update own portfolio" ON public.portfolios;

CREATE POLICY "Users can update own portfolio" ON public.portfolios FOR
UPDATE USING (
    (
        SELECT
            auth.uid ()
    ) = user_id
)
WITH
    CHECK (
        (
            SELECT
                auth.uid ()
        ) = user_id
    );