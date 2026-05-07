-- posts 테이블의 user_id 컬럼에 인덱스 생성
CREATE INDEX IF NOT EXISTS idx_posts_user_id ON public.posts (user_id);

-- posts 테이블의 portfolio_snapshot_id 컬럼에 인덱스 생성
CREATE INDEX IF NOT EXISTS idx_posts_portfolio_snapshot_id ON public.posts (portfolio_snapshot_id);

-- posts 테이블의 deleted_at 컬럼에 부분 인덱스 생성
CREATE INDEX IF NOT EXISTS idx_posts_active_latest ON public.posts (created_at DESC)
WHERE
    deleted_at IS NULL;