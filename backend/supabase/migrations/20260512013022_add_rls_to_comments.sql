ALTER TABLE comments ENABLE ROW LEVEL SECURITY;

-- SELECT : 삭제되지 않은 댓글은 누구나 조회 가능
CREATE POLICY "Anyone can view comments" ON comments FOR
SELECT
    USING (deleted_at IS NULL);

-- INSERT : 본인 명의로만 댓글 작성 가능
CREATE POLICY "Users can insert own comments" ON comments FOR INSERT
WITH
    CHECK (
        user_id = (
            SELECT
                auth.uid ()
        )
    );

-- UPDATE : 본인 댓글만 수정 가능
CREATE POLICY "Users can update own comments" ON comments FOR
UPDATE USING (
    user_id = (
        SELECT
            auth.uid ()
    )
)
WITH
    CHECK (
        user_id = (
            SELECT
                auth.uid ()
        )
    );

-- DELETE : 본인 댓글만 물리적으로 삭제 가능 (필요 시)
CREATE POLICY "Users can delete own comments" ON comments FOR DELETE USING (
    user_id = (
        SELECT
            auth.uid ()
    )
);