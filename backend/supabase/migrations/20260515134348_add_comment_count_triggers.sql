-- 2. 트리거 설정
-- comments 테이블의 INSERT, UPDATE, DELETE 이벤트 발생 후 함수를 실행하도록 설정합니다.
-- 2. 트리거 설정
-- comments 테이블의 INSERT, UPDATE, DELETE 이벤트 발생 후 함수를 실행하도록 설정합니다.
-- 기존 트리거가 있다면 삭제 (중복 생성 방지)
DROP TRIGGER IF EXISTS on_comment_created ON public.comments;

DROP TRIGGER IF EXISTS on_comment_updated_count ON public.comments;

DROP TRIGGER IF EXISTS on_comment_deleted ON public.comments;

-- 댓글 생성 시 실행
CREATE TRIGGER on_comment_created AFTER INSERT ON public.comments FOR EACH ROW EXECUTE FUNCTION public.handle_comment_count_update ();

-- 댓글 수정 시 실행 (Soft Delete 감지용)
CREATE TRIGGER on_comment_updated_count AFTER
UPDATE ON public.comments FOR EACH ROW EXECUTE FUNCTION public.handle_comment_count_update ();

-- 댓글 물리 삭제 시 실행
CREATE TRIGGER on_comment_deleted AFTER DELETE ON public.comments FOR EACH ROW EXECUTE FUNCTION public.handle_comment_count_update ();