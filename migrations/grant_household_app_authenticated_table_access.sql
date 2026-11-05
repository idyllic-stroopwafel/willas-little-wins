-- Applied to Supabase project jtumxiubazzihsmtkgzy.
-- The RLS policies in supabase.sql remain responsible for household isolation.
grant select on table public.households, public.memberships to authenticated;
grant select, insert on table public.entries, public.assets to authenticated;
revoke all on table public.households, public.memberships, public.entries, public.assets from anon;
