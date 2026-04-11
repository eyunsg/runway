-- portfolios 테이블의 user_id 컬럼에 인덱스를 생성하여 전체 테이블 스캔 방지
CREATE INDEX IF NOT EXISTS idx_portfolios_user_id ON public.portfolios (user_id);