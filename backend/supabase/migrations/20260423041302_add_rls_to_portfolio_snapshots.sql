ALTER TABLE portfolio_snapshots ENABLE ROW LEVEL SECURITY;

-- SELECT : 삭제되지 않은 모든 스냅샷은 커뮤니티 게시물을 통해 누구나 조회 가능
CREATE POLICY "Anyone can view portfolio snapshots" ON portfolio_snapshots FOR
SELECT
    USING (deleted_at IS NULL);

-- INSERT : 본인 포트폴리오의 스냅샷만 생성 가능
CREATE POLICY "Users can insert own portfolio snapshots" ON portfolio_snapshots FOR INSERT
WITH
    CHECK (
        EXISTS (
            SELECT
                1
            FROM
                portfolios
            WHERE
                portfolios.id = portfolio_id
                AND portfolios.user_id = (
                    SELECT
                        auth.uid ()
                )
        )
    );

-- UPDATE : 본인 포트폴리오의 스냅샷만 수정 가능
CREATE POLICY "Users can update own portfolio snapshots" ON portfolio_snapshots FOR
UPDATE USING (
    EXISTS (
        SELECT
            1
        FROM
            portfolios
        WHERE
            portfolios.id = portfolio_id
            AND portfolios.user_id = (
                SELECT
                    auth.uid ()
            )
    )
)
WITH
    CHECK (
        EXISTS (
            SELECT
                1
            FROM
                portfolios
            WHERE
                portfolios.id = portfolio_id
                AND portfolios.user_id = (
                    SELECT
                        auth.uid ()
                )
        )
    );

-- DELETE : 본인 포트폴리오의 스냅샷만 삭제 가능
CREATE POLICY "Users can delete own portfolio snapshots" ON portfolio_snapshots FOR DELETE USING (
    EXISTS (
        SELECT
            1
        FROM
            portfolios
        WHERE
            portfolios.id = portfolio_id
            AND portfolios.user_id = (
                SELECT
                    auth.uid ()
            )
    )
);