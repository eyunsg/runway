-- 1. DELETE RLS 정책 추가 (성능 향상을 위한 (select auth.uid()) 서브쿼리 적용)
DROP POLICY IF EXISTS "Users can delete own profile" ON public.profiles;

CREATE POLICY "Users can delete own profile" ON public.profiles FOR DELETE USING (
    (
        select
            auth.uid ()
    ) = id
);