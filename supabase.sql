-- Run once in the SQL editor of a fresh Supabase project.
-- Each person signs in with their own email. An unguessable household code joins them.
-- Uses built-in gen_random_uuid() for cryptographically random household invite codes.

create table if not exists public.households (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  invite_code text not null unique,
  created_at timestamptz not null default now()
);
create table if not exists public.memberships (
  user_id uuid primary key references auth.users(id) on delete cascade,
  household_id uuid not null references public.households(id) on delete cascade,
  display_name text not null check (display_name in ('Hil','Peter')),
  unique(household_id,display_name)
);
create table if not exists public.assets (
  id uuid primary key,
  household_id uuid not null references public.households(id) on delete cascade,
  path text not null,
  type text not null check (type in ('photo','portrait','sticker')),
  pet_name text,
  caption text not null default '',
  sticker_code text not null default '',
  created_by uuid not null references auth.users(id),
  created_by_name text not null check (created_by_name in ('Hil','Peter')),
  created_at timestamptz not null default now()
);
create table if not exists public.entries (
  id uuid primary key,
  household_id uuid not null references public.households(id) on delete cascade,
  user_id uuid not null references auth.users(id),
  activity text not null check (activity in ('den','cues','blink','wait')),
  comfort text not null check (comfort in ('comfy','unsure','hard')),
  note text not null default '',
  photo_asset_id uuid references public.assets(id),
  sticker_code text not null default '⭐',
  actor text not null check (actor in ('Hil','Peter')),
  created_at timestamptz not null default now()
);
create index if not exists entries_house_time on public.entries(household_id,created_at desc);
create index if not exists assets_house_time on public.assets(household_id,created_at desc);

alter table public.households enable row level security;
alter table public.memberships enable row level security;
alter table public.assets enable row level security;
alter table public.entries enable row level security;

create policy "member reads own membership" on public.memberships for select to authenticated using (user_id=auth.uid());
create policy "member reads household" on public.households for select to authenticated using (
  exists (select 1 from public.memberships m where m.household_id=households.id and m.user_id=auth.uid())
);
create policy "member reads assets" on public.assets for select to authenticated using (
  exists (select 1 from public.memberships m where m.household_id=assets.household_id and m.user_id=auth.uid())
);
create policy "member adds assets" on public.assets for insert to authenticated with check (
  created_by=auth.uid() and exists (select 1 from public.memberships m where m.household_id=assets.household_id and m.user_id=auth.uid() and m.display_name=assets.created_by_name)
  and split_part(path,'/',1)=household_id::text
);
create policy "member reads entries" on public.entries for select to authenticated using (
  exists (select 1 from public.memberships m where m.household_id=entries.household_id and m.user_id=auth.uid())
);
create policy "member adds entries" on public.entries for insert to authenticated with check (
  user_id=auth.uid() and exists (select 1 from public.memberships m where m.household_id=entries.household_id and m.user_id=auth.uid() and m.display_name=entries.actor)
  and (photo_asset_id is null or exists (select 1 from public.assets a where a.id=photo_asset_id and a.household_id=entries.household_id))
);

-- Access to create/join flows via security-definer functions, not direct public inserts.
create or replace function public.create_household(p_name text,p_display_name text)
returns uuid language plpgsql security definer set search_path = '' as $$
declare hid uuid; c text;
begin
 if auth.uid() is null then raise exception 'Sign in first'; end if;
 if p_display_name not in ('Hil','Peter') then raise exception 'Unknown profile'; end if;
 if exists(select 1 from public.memberships where user_id=auth.uid()) then raise exception 'Already joined'; end if;
 c := left(replace(pg_catalog.gen_random_uuid()::text,'-',''),14);
 insert into public.households(name,invite_code) values (left(p_name,70),c) returning id into hid;
 insert into public.memberships(user_id,household_id,display_name) values(auth.uid(),hid,p_display_name);
 return hid;
end $$;
create or replace function public.join_household(p_code text,p_display_name text)
returns uuid language plpgsql security definer set search_path = '' as $$
declare hid uuid;
begin
 if auth.uid() is null then raise exception 'Sign in first'; end if;
 if p_display_name not in ('Hil','Peter') then raise exception 'Unknown profile'; end if;
 if exists(select 1 from public.memberships where user_id=auth.uid()) then raise exception 'Already joined'; end if;
 select id into hid from public.households where invite_code=lower(trim(p_code));
 if hid is null then raise exception 'Household code not found'; end if;
 if (select count(*) from public.memberships where household_id=hid)>=2 then raise exception 'This household already has two people'; end if;
 insert into public.memberships(user_id,household_id,display_name) values(auth.uid(),hid,p_display_name);
 return hid;
end $$;
revoke all on function public.create_household(text,text) from public;
revoke all on function public.join_household(text,text) from public;
grant execute on function public.create_household(text,text) to authenticated;
grant execute on function public.join_household(text,text) to authenticated;

insert into storage.buckets(id,name,public,file_size_limit,allowed_mime_types)
values ('pet_media','pet_media',false,5242880,array['image/jpeg','image/png','image/webp'])
on conflict (id) do nothing;
create policy "household members upload photos" on storage.objects for insert to authenticated with check (
  bucket_id='pet_media' and exists (select 1 from public.memberships m where m.household_id::text=(storage.foldername(name))[1] and m.user_id=auth.uid())
);
create policy "household members read photos" on storage.objects for select to authenticated using (
  bucket_id='pet_media' and exists (select 1 from public.memberships m where m.household_id::text=(storage.foldername(name))[1] and m.user_id=auth.uid())
);
create policy "household members delete their photos" on storage.objects for delete to authenticated using (
  bucket_id='pet_media' and exists (select 1 from public.memberships m where m.household_id::text=(storage.foldername(name))[1] and m.user_id=auth.uid())
);
-- Live refresh when the other person logs something.
alter publication supabase_realtime add table public.entries;
alter publication supabase_realtime add table public.assets;
