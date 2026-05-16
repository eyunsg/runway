-- 3. 초기 데이터 동기화
-- 트리거가 작동하기 전의 데이터 불일치를 해결하기 위해 현재 활성 댓글 수를 기준으로 업데이트합니다.
UPDATE public.posts p
SET
    comments_count = (
        SELECT
            count(*)
        FROM
            public.comments c
        WHERE
            c.post_id = p.id
            AND c.deleted_at IS NULL
    );