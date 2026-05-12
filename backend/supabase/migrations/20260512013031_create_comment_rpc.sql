create
or replace function public.create_comment_with_count (p_post_id uuid, p_content text) returns uuid language sql security definer
set
    search_path = public begin atomic
with
    inserted_comment as (
        insert into
            public.comments (post_id, user_id, content)
        select
            p_post_id,
            auth.uid (),
            p_content
        where
            auth.uid () is not null
            and exists (
                select
                    1
                from
                    public.posts
                where
                    id = p_post_id
                    and deleted_at is null
            ) returning id
    ),
    update_post_count as (
        update public.posts
        set
            comments_count = comments_count + 1,
            updated_at = now ()
        where
            id = p_post_id
            and exists (
                select
                    1
                from
                    inserted_comment
            )
    )
select
    id
from
    inserted_comment;

end;