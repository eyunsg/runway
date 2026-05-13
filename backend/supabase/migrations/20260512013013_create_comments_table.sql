-- 1. comments 테이블 생성 (스키마 정의)
CREATE TABLE
    comments (
        id UUID PRIMARY KEY DEFAULT gen_random_uuid (),
        post_id UUID NOT NULL REFERENCES posts (id) ON DELETE CASCADE,
        user_id UUID NOT NULL REFERENCES profiles (id) ON DELETE CASCADE,
        content TEXT NOT NULL,
        created_at TIMESTAMP
        WITH
            TIME ZONE NOT NULL DEFAULT now (),
            updated_at TIMESTAMP
        WITH
            TIME ZONE NOT NULL DEFAULT now (),
            deleted_at TIMESTAMP
        WITH
            TIME ZONE,
            CONSTRAINT content_not_empty CHECK (content <> '')
    );

-- 2. updated_at 자동 갱신 트리거 설정
CREATE TRIGGER update_comments_updated_at BEFORE
UPDATE ON comments FOR EACH ROW EXECUTE PROCEDURE handle_updated_at ();

-- 3. 성능 최적화를 위한 인덱스 생성
CREATE INDEX IF NOT EXISTS idx_comments_post_id ON public.comments (post_id);

CREATE INDEX IF NOT EXISTS idx_comments_user_id ON public.comments (user_id);

CREATE INDEX IF NOT EXISTS idx_comments_active_latest ON public.comments (created_at DESC)
WHERE
    deleted_at IS NULL;