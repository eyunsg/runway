-- public.delete_post_and_snapshot 함수의 보안(search_path) 취약점 해결을 위한 마이그레이션
CREATE OR REPLACE FUNCTION public.delete_post_and_snapshot(p_post_id uuid)
RETURNS boolean
LANGUAGE plpgsql
SECURITY DEFINER                  -- 어드민 권한으로 안전하게 고정 실행
SET search_path = public          -- 핵심: search_path를 public으로 강제 고정하여 보안 경고 해결
AS $$
DECLARE
  v_snapshot_id uuid;
BEGIN
  -- posts 테이블 소프트 딜리트
  UPDATE public.posts
  SET deleted_at = now()
  WHERE id = p_post_id
    AND deleted_at IS NULL;

  IF NOT FOUND THEN
    RETURN false;
  END IF;

  -- 연결된 스냅샷 ID 조회
  SELECT portfolio_snapshot_id
  INTO v_snapshot_id
  FROM public.posts
  WHERE id = p_post_id;

  -- portfolio_snapshots 테이블 소프트 딜리트
  UPDATE public.portfolio_snapshots
  SET deleted_at = now()
  WHERE id = v_snapshot_id
    AND v_snapshot_id IS NOT NULL
    AND deleted_at IS NULL;

  RETURN true;
END;
$$;