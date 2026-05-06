ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Users can view own profile" ON profiles;

-- SELECT : 모든 사용자가 프로필을 조회할 수 있도록 허용
CREATE POLICY "Public profiles are viewable by everyone" ON profiles FOR
SELECT
    USING (true);