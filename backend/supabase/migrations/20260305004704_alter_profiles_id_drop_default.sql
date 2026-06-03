-- profiles.id 컬럼의 DEFAULT 제거
ALTER TABLE public.profiles
ALTER COLUMN id
DROP DEFAULT;