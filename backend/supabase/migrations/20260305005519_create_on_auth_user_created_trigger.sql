-- auth.users에 새 유저 생성 시 handle_new_user 트리거 실행
create trigger on_auth_user_created after insert on auth.users for each row execute function public.handle_new_user ();