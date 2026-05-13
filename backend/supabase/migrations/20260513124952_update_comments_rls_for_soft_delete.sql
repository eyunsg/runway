-- comments RLS 정책 수정
-- soft delete 지원 및 본인 삭제 댓글 조회 가능하도록 변경
ALTER TABLE comments ENABLE ROW LEVEL SECURITY;

-- 기존 정책 제거
DROP POLICY IF EXISTS "Anyone can view comments" ON comments;

DROP POLICY IF EXISTS "Users can insert own comments" ON comments;

DROP POLICY IF EXISTS "Users can update own comments" ON comments;

DROP POLICY IF EXISTS "Users can delete own comments" ON comments;

-- SELECT
-- 일반 사용자는 삭제되지 않은 댓글만 조회 가능
-- 작성자는 자신의 삭제된 댓글도 조회 가능
CREATE POLICY "Anyone can view comments" ON comments FOR
SELECT
    USING (
        deleted_at IS NULL
        OR auth.uid () = user_id
    );

-- INSERT
-- 본인 명의로만 댓글 작성 가능
CREATE POLICY "Users can insert own comments" ON comments FOR INSERT
WITH
    CHECK (auth.uid () = user_id);

-- UPDATE
-- 본인 댓글만 수정 가능
CREATE POLICY "Users can update own comments" ON comments FOR
UPDATE USING (auth.uid () = user_id)
WITH
    CHECK (auth.uid () = user_id);

-- DELETE
-- 본인 댓글만 물리 삭제 가능
CREATE POLICY "Users can delete own comments" ON comments FOR DELETE USING (auth.uid () = user_id);