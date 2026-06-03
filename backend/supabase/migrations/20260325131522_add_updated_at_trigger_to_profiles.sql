drop trigger if exists trigger_profiles_updated_at on public.profiles;

create trigger trigger_profiles_updated_at before
update on public.profiles for each row execute function public.handle_updated_at ();