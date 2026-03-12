-- 1. Posts 테이블 생성
CREATE TABLE
    IF NOT EXISTS public.posts (
        id UUID DEFAULT gen_random_uuid () PRIMARY KEY,
        user_id UUID NOT NULL REFERENCES public.profiles (id) ON DELETE CASCADE,
        content TEXT NOT NULL,
        comments_count INTEGER DEFAULT 0 NOT NULL,
        created_at TIMESTAMP
        WITH
            TIME ZONE DEFAULT now () NOT NULL,
            updated_at TIMESTAMP
        WITH
            TIME ZONE DEFAULT now () NOT NULL,
            deleted_at TIMESTAMP
        WITH
            TIME ZONE -- Soft Delete
    );

-- 2. 성능 최적화: 유저별 게시물 조회를 위한 인덱스
CREATE INDEX IF NOT EXISTS idx_posts_user_id ON public.posts (user_id);

-- 3. 보안 설정 (Row Level Security)
ALTER TABLE public.posts ENABLE ROW LEVEL SECURITY;

-- 조회: 모든 사용자가 볼 수 있음 (Soft Delete된 것은 제외)
CREATE POLICY "Everyone can view posts" ON public.posts FOR
SELECT
    USING (deleted_at IS NULL);

-- 생성/수정/삭제: 본인만 가능
CREATE POLICY "Users can insert own posts" ON public.posts FOR INSERT
WITH
    CHECK (auth.uid () = user_id);

CREATE POLICY "Users can update own posts" ON public.posts FOR
UPDATE USING (auth.uid () = user_id);