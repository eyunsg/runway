create
or replace function public.delete_comment_with_count (p_comment_id uuid) returns boolean language sql security definer
set
    search_path = public begin atomic
with
    updated_comment as (
        update public.comments
        set
            deleted_at = now (),
            updated_at = now ()
        where
            id = p_comment_id
            and user_id = auth.uid ()
            and deleted_at is null returning post_id
    ),
    update_post as (
        update public.posts
        set
            comments_count = greatest (0, comments_count - 1),
            updated_at = now ()
        where
            id = (
                select
                    post_id
                from
                    updated_comment
            )
            and deleted_at is null
    )
select
    exists (
        select
            1
        from
            updated_comment
    );

end;