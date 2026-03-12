-- 1. Portfolios 테이블 생성
CREATE TABLE
    IF NOT EXISTS public.portfolios (
        id UUID DEFAULT gen_random_uuid () PRIMARY KEY,
        user_id UUID NOT NULL REFERENCES public.profiles (id) ON DELETE CASCADE,
        name TEXT NOT NULL,
        -- 파싱 에러 방지를 위해 CAST 문법 사용
        simulation_input JSONB DEFAULT CAST('{}' AS JSONB),
        simulation_result JSONB DEFAULT CAST('{}' AS JSONB),
        created_at TIMESTAMP
        WITH
            TIME ZONE DEFAULT now () NOT NULL,
            updated_at TIMESTAMP
        WITH
            TIME ZONE DEFAULT now () NOT NULL,
            deleted_at TIMESTAMP
        WITH
            TIME ZONE -- Soft Delete 필드
    );

-- 2. 성능 최적화: 유저별 조회를 위한 인덱스
CREATE INDEX IF NOT EXISTS idx_portfolios_user_id ON public.portfolios (user_id);

-- 3. 보안 설정 (Row Level Security)
ALTER TABLE public.portfolios ENABLE ROW LEVEL SECURITY;

-- 조회: 본인의 데이터만 조회 가능
CREATE POLICY "Users can view own portfolios" ON public.portfolios FOR
SELECT
    USING (auth.uid () = user_id);

-- 생성: 본인 유저 ID로만 생성 가능
CREATE POLICY "Users can insert own portfolios" ON public.portfolios FOR INSERT
WITH
    CHECK (auth.uid () = user_id);

-- 수정: 본인의 데이터만 수정 가능
CREATE POLICY "Users can update own portfolios" ON public.portfolios FOR
UPDATE USING (auth.uid () = user_id);