-- portfolio_snapshots 테이블의 portfolio_id 컬럼에 인덱스를 생성하여 조인 및 RLS 소유권 확인 성능 향상
CREATE INDEX IF NOT EXISTS idx_portfolio_snapshots_portfolio_id ON public.portfolio_snapshots (portfolio_id);

-- portfolio_snapshots 테이블의 deleted_at 컬럼에 부분 인덱스를 생성하여 삭제되지 않은 스냅샷 조회 성능 최적화
CREATE INDEX IF NOT EXISTS idx_portfolio_snapshots_active ON public.portfolio_snapshots (created_at DESC)
WHERE
    deleted_at IS NULL;