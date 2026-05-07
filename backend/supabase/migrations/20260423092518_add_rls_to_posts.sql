ALTER TABLE posts ENABLE ROW LEVEL SECURITY;

-- SELECT : 삭제되지 않은 모든 게시글은 누구나 조회 가능
CREATE POLICY "Anyone can view posts" ON posts FOR
SELECT
    USING (deleted_at IS NULL);

-- INSERT : 본인 명의로만 게시글 작성 가능
CREATE POLICY "Users can insert own posts" ON posts FOR INSERT
WITH
    CHECK (
        user_id = (
            SELECT
                auth.uid ()
        )
    );

-- UPDATE : 본인 게시글만 수정 가능
CREATE POLICY "Users can update own posts" ON posts FOR
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

-- DELETE : 본인 게시글만 삭제 가능
CREATE POLICY "Users can delete own posts" ON posts FOR DELETE USING (
    user_id = (
        SELECT
            auth.uid ()
    )
);