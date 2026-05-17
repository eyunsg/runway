CREATE OR REPLACE FUNCTION handle_comment_count_update()
RETURNS TRIGGER AS $$
BEGIN
    -- [CASE 1] 새로운 댓글이 생성되었을 때
    IF (TG_OP = 'INSERT') THEN
        UPDATE posts 
        SET comments_count = comments_count + 1 
        WHERE id = NEW.post_id;
        RETURN NEW;

    -- [CASE 2] 댓글의 상태가 변경되었을 때 (Soft Delete 처리 포함)
    ELSIF (TG_OP = 'UPDATE') THEN
        -- Soft Delete 발생: deleted_at이 NULL이었다가 값이 채워질 때
        IF (OLD.deleted_at IS NULL AND NEW.deleted_at IS NOT NULL) THEN
            UPDATE posts 
            SET comments_count = comments_count - 1 
            WHERE id = NEW.post_id;
        
        -- Soft Delete 복구: deleted_at에 값이 있다가 다시 NULL이 될 때
        ELSIF (OLD.deleted_at IS NOT NULL AND NEW.deleted_at IS NULL) THEN
            UPDATE posts 
            SET comments_count = comments_count + 1 
            WHERE id = NEW.post_id;
        END IF;
        RETURN NEW;

    -- [CASE 3] 실제로 데이터가 삭제되었을 때 (Hard Delete)
    ELSIF (TG_OP = 'DELETE') THEN
        -- 이미 Soft Delete 되어 카운트가 깎인 상태가 아닐 때만 카운트 감소
        IF (OLD.deleted_at IS NULL) THEN
            UPDATE posts 
            SET comments_count = comments_count - 1 
            WHERE id = OLD.post_id;
        END IF;
        RETURN OLD;
    END IF;

    RETURN NULL;
END;
$$ 
LANGUAGE plpgsql 
SECURITY DEFINER 
SET search_path = public;