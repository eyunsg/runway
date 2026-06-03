-- handle_new_user 트리거 함수 생성
create or replace function public.handle_new_user()
returns trigger as $$
begin
    insert into public.profiles (
        id,
        display_name
    ) values (
        NEW.id,
        NEW.raw_user_meta_data ->> 'displayName'
    );
    return NEW;
end;
$$ language plpgsql security definer;