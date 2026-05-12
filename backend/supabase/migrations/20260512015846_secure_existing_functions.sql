-- 1. 기존에 작성된 게시글/스냅샷 삭제 함수 보안 설정
alter function public.delete_post_and_snapshot (p_post_id uuid)
set
    search_path = public;

-- 2. 프로젝트 공통으로 사용되는 타임스탬프 갱신 트리거 함수 보안 설정
alter function public.handle_updated_at ()
set
    search_path = public;