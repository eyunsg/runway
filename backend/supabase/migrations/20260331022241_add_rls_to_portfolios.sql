ALTER TABLE portfolios ENABLE ROW LEVEL SECURITY;

-- SELECT : 본인 포트폴리오만 조회 가능
CREATE POLICY "Users can view own portfolio" ON portfolios FOR
SELECT
    USING (auth.uid () = user_id);

-- INSERT : 본인 포트폴리오만 생성 가능
CREATE POLICY "Users can insert own portfolio" ON portfolios FOR INSERT
WITH
    CHECK (auth.uid () = user_id);

-- UPDATE : 본인 포트폴리오만 수정 가능
CREATE POLICY "Users can update own portfolio" ON portfolios FOR
UPDATE USING (auth.uid () = user_id)
WITH
    CHECK (auth.uid () = user_id);