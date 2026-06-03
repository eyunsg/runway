ALTER TABLE profiles
ENABLE ROW LEVEL SECURITY;

-- SELECT : 본인 프로필만 조회 가능
CREATE POLICY "Users can view own profile"
ON profiles
FOR SELECT
USING (
  auth.uid() = id
);

-- INSERT : 본인 프로필만 생성 가능
CREATE POLICY "Users can insert own profile"
ON profiles
FOR INSERT
WITH CHECK (
  auth.uid() = id
);

-- UPDATE : 본인 프로필만 수정 가능
CREATE POLICY "Users can update own profile"
ON profiles
FOR UPDATE
USING (
  auth.uid() = id
)
WITH CHECK (
  auth.uid() = id
);