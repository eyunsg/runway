-- 함수 실행 시 스키마 경로를 public으로 고정하여 검색 경로 가로채기 공격 방지
ALTER FUNCTION public.handle_new_user ()
SET
    search_path = public;

ALTER FUNCTION public.handle_updated_at ()
SET
    search_path = public;