-- 2. 회원가입 트리거 함수 개선 (도메인 2~20자 만족 보장 + Search Path 고정 보안 최적화)
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS trigger AS $$
DECLARE
    final_display_name VARCHAR(50);
BEGIN
    -- 1단계: 메타데이터 검색 -> 이메일 아이디 -> 임시 사용자 순으로 초기 값 확보
    final_display_name := COALESCE(
        NEW.raw_user_meta_data ->> 'displayName',
        NEW.raw_user_meta_data ->> 'name',
        SPLIT_PART(NEW.email, '@', 1),
        'User_' || SUBSTR(NEW.id::text, 1, 8)
    );

    -- 2단계: 도메인 제약조건 만족을 위해 공백 제거 및 글자 수 가공 (최소 2자 보장)
    final_display_name := TRIM(final_display_name);
    IF LENGTH(final_display_name) < 2 THEN
        final_display_name := final_display_name || '_user';
    END IF;

    -- 3단계: 도메인 제약조건 최대 20자 제한 엄수
    final_display_name := SUBSTRING(final_display_name FROM 1 FOR 20);

    INSERT INTO public.profiles (
        id,
        display_name
    ) VALUES (
        NEW.id,
        final_display_name
    );
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public;
