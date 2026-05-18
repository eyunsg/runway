create or replace function delete_post_and_snapshot(p_post_id uuid)
returns boolean
language plpgsql
as $$
declare
  v_snapshot_id uuid;
begin
  update posts
  set deleted_at = now()
  where id = p_post_id
    and deleted_at is null;

  if not found then
    return false;
  end if;

  select portfolio_snapshot_id
  into v_snapshot_id
  from posts
  where id = p_post_id;

  update portfolio_snapshots
  set deleted_at = now()
  where id = v_snapshot_id
    and v_snapshot_id is not null
    and deleted_at is null;

  return true;
end;
$$;