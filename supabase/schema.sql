-- KKO responses schema. RLS protects all browser-facing access.
create schema if not exists private;

create table if not exists public.responses (
  id uuid primary key default gen_random_uuid(),
  created_at timestamptz not null default now(),
  answers jsonb not null
);

-- Keep the administrator allowlist outside the exposed public API schema.
create table if not exists private.admin_users (
  user_id uuid primary key references auth.users(id) on delete cascade
);

alter table public.responses enable row level security;
alter table private.admin_users enable row level security;

drop policy if exists "Admins can read their own allowlist entry" on private.admin_users;
create policy "Admins can read their own allowlist entry"
  on private.admin_users for select to authenticated
  using ((select auth.uid()) = user_id);

drop policy if exists "Anyone can submit KKO responses" on public.responses;
create policy "Anyone can submit KKO responses"
  on public.responses for insert to anon
  with check (jsonb_typeof(answers) = 'object');

create or replace function private.is_kko_admin()
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select exists (
    select 1 from private.admin_users
    where user_id = (select auth.uid())
  );
$$;
revoke all on function private.is_kko_admin() from public;
grant usage on schema private to authenticated;
grant select on private.admin_users to authenticated;
grant execute on function private.is_kko_admin() to authenticated;

drop policy if exists "Authenticated admins can read KKO responses" on public.responses;
create policy "Authenticated admins can read KKO responses"
  on public.responses for select to authenticated
  using (private.is_kko_admin());

grant usage on schema public to anon, authenticated;
grant insert on public.responses to anon;
grant select on public.responses to authenticated;
