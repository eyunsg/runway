-- 1. 기존 정책 제거
-- 성능 최적화 버전으로 다시 만들기 위해 기존 정책들을 먼저 제거합니다.
DROP POLICY IF EXISTS "Anyone can view comments" ON public.comments;

DROP POLICY IF EXISTS "Users can insert own comments" ON public.comments;

DROP POLICY IF EXISTS "Users can update own comments" ON public.comments;

DROP POLICY IF EXISTS "Users can delete own comments" ON public.comments;

-- 2. 성능이 최적화된 정책 생성
-- auth.uid() 대신 (SELECT auth.uid()) 서브쿼리를 사용하여 성능을 개선합니다.
-- SELECT: 일반 사용자는 삭제되지 않은 댓글만, 작성자는 본인 댓글(삭제 포함) 조회 가능
CREATE POLICY "Anyone can view comments" ON public.comments FOR
SELECT
    USING (
        deleted_at IS NULL
        OR (
            SELECT
                auth.uid ()
        ) = user_id
    );

-- INSERT: 본인 세션의 ID로만 댓글 작성 가능
CREATE POLICY "Users can insert own comments" ON public.comments FOR INSERT
WITH
    CHECK (
        (
            SELECT
                auth.uid ()
        ) = user_id
    );

-- UPDATE: 본인 댓글만 수정 가능
CREATE POLICY "Users can update own comments" ON public.comments FOR
UPDATE USING (
    (
        SELECT
            auth.uid ()
    ) = user_id
)
WITH
    CHECK (
        (
            SELECT
                auth.uid ()
        ) = user_id
    );

-- DELETE: 본인 댓글만 물리 삭제 가능
CREATE POLICY "Users can delete own comments" ON public.comments FOR DELETE USING (
    (
        SELECT
            auth.uid ()
    ) = user_id
);