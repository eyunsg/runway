-- 3. 데이터 무결성을 위한 외래키(Foreign Key) 제약 조건 및 Cascade 설정 추가
ALTER TABLE public.profiles
DROP CONSTRAINT IF EXISTS fk_profiles_user_id;

ALTER TABLE public.profiles ADD CONSTRAINT fk_profiles_user_id FOREIGN KEY (id) REFERENCES auth.users (id) ON DELETE CASCADE;