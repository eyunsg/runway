-- delete_post_and_snapshot RPC 권한 검증 추가
-- 다른 사용자가 타인의 게시글을 삭제하지 못하도록 수정

CREATE OR REPLACE FUNCTION public.delete_post_and_snapshot(
  p_post_id uuid
)
RETURNS boolean
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_snapshot_id uuid;
BEGIN
  -- 게시글 소프트 삭제
  -- 작성자 본인만 삭제 가능
  UPDATE public.posts
  SET deleted_at = now()
  WHERE id = p_post_id
    AND user_id = auth.uid()
    AND deleted_at IS NULL;

  -- 삭제 대상이 없으면 권한 없음 또는 이미 삭제됨
  IF NOT FOUND THEN
    RETURN false;
  END IF;

  -- 연결된 스냅샷 조회
  SELECT portfolio_snapshot_id
  INTO v_snapshot_id
  FROM public.posts
  WHERE id = p_post_id;

  -- 연결된 포트폴리오 스냅샷 소프트 삭제
  UPDATE public.portfolio_snapshots
  SET deleted_at = now()
  WHERE id = v_snapshot_id
    AND v_snapshot_id IS NOT NULL
    AND deleted_at IS NULL;

  RETURN true;
END;
$$;