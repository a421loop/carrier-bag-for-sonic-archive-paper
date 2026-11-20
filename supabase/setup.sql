-- Carrier bag: database setup for Supabase.
-- Paste this whole file into Supabase → SQL Editor → New query → Run. Safe to run again.

-- ---------- baskets ----------
create table if not exists public.bags (
  id       text primary key,
  owner    uuid not null default auth.uid() references auth.users (id) on delete cascade,
  name     text not null default 'basket',
  created  bigint not null,
  shared   boolean not null default false,
  members  uuid[] not null default '{}',     -- friends who opened a shared basket's link
  flowers  jsonb not null default '{}'::jsonb -- { flowerId: { name, x, plays, lastPlayed, added, color, draw, audio, by } }
);

alter table public.bags enable row level security;

-- only signed-in people reach the table through the API (the rules below decide which rows)
revoke all on public.bags from anon;
grant select, insert, update, delete on public.bags to authenticated;

-- you see your own baskets, and shared baskets you've joined
drop policy if exists "read own or joined" on public.bags;
create policy "read own or joined" on public.bags for select to authenticated
  using (owner = auth.uid() or (shared and auth.uid() = any (members)));

drop policy if exists "create own" on public.bags;
create policy "create own" on public.bags for insert to authenticated
  with check (owner = auth.uid());

-- you change your own baskets; friends change shared ones they've joined (plays, adding sounds)
drop policy if exists "change own or joined" on public.bags;
create policy "change own or joined" on public.bags for update to authenticated
  using (owner = auth.uid() or (shared and auth.uid() = any (members)))
  with check (owner = auth.uid() or (shared and auth.uid() = any (members)));

drop policy if exists "delete own" on public.bags;
create policy "delete own" on public.bags for delete to authenticated
  using (owner = auth.uid());

-- ---------- small helpers, so two people tapping at once never overwrite each other ----------

-- opening a shared basket's link adds you to it
create or replace function public.join_bag(bag_id text) returns void
language sql security definer set search_path = public as $$
  update bags set members = array_append(members, auth.uid())
  where id = bag_id and shared and auth.uid() is not null and not (auth.uid() = any (members)) and owner <> auth.uid();
$$;

create or replace function public.add_flower(bag_id text, flower jsonb) returns void
language sql security invoker set search_path = public as $$
  update bags set flowers = flowers || jsonb_build_object(flower->>'id', flower) where id = bag_id;
$$;

create or replace function public.patch_flower(bag_id text, fid text, patch jsonb) returns void
language sql security invoker set search_path = public as $$
  update bags set flowers = jsonb_set(flowers, array[fid], coalesce(flowers->fid, '{}'::jsonb) || patch)
  where id = bag_id and flowers ? fid;
$$;

create or replace function public.play_flower(bag_id text, fid text) returns void
language sql security invoker set search_path = public as $$
  update bags set flowers = jsonb_set(flowers, array[fid],
    (flowers->fid) || jsonb_build_object(
      'plays', coalesce((flowers->fid->>'plays')::int, 0) + 1,
      'lastPlayed', (extract(epoch from now()) * 1000)::bigint))
  where id = bag_id and flowers ? fid;
$$;

create or replace function public.remove_flower(bag_id text, fid text) returns void
language sql security invoker set search_path = public as $$
  update bags set flowers = flowers - fid where id = bag_id;
$$;

grant execute on function public.join_bag(text), public.add_flower(text, jsonb), public.patch_flower(text, text, jsonb),
  public.play_flower(text, text), public.remove_flower(text, text) to authenticated;

-- live updates when a friend plays or adds something
do $$ begin
  alter publication supabase_realtime add table public.bags;
exception when duplicate_object then null; end $$;

-- ---------- audio files ----------
insert into storage.buckets (id, name, public) values ('audio', 'audio', false)
on conflict (id) do nothing;

-- files live at  audio/<your user id>/<file id>
drop policy if exists "upload own audio" on storage.objects;
create policy "upload own audio" on storage.objects for insert to authenticated
  with check (bucket_id = 'audio' and (storage.foldername(name))[1] = auth.uid()::text);

drop policy if exists "listen to audio" on storage.objects;
create policy "listen to audio" on storage.objects for select to authenticated
  using (bucket_id = 'audio');   -- file names are long random ids, only known to people who can see the basket

drop policy if exists "delete own audio" on storage.objects;
create policy "delete own audio" on storage.objects for delete to authenticated
  using (bucket_id = 'audio' and (storage.foldername(name))[1] = auth.uid()::text);
