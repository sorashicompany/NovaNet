create table if not exists public.novanet_subscriptions (
  id uuid primary key default gen_random_uuid(),
  owner_id uuid not null references auth.users(id) on delete cascade,
  name text not null check (char_length(name) between 1 and 120),
  access_token_hash text not null unique,
  description text,
  traffic_used_mb numeric not null default 0 check (traffic_used_mb >= 0),
  traffic_limit_mb numeric check (traffic_limit_mb is null or traffic_limit_mb >= 0),
  version integer not null default 1,
  expires_at timestamptz,
  profiles jsonb not null default '[]'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

alter table public.novanet_subscriptions enable row level security;
create policy "novanet owners select subscriptions" on public.novanet_subscriptions for select to authenticated using ((select auth.uid()) = owner_id);
create policy "novanet owners insert subscriptions" on public.novanet_subscriptions for insert to authenticated with check ((select auth.uid()) = owner_id);
create policy "novanet owners update subscriptions" on public.novanet_subscriptions for update to authenticated using ((select auth.uid()) = owner_id) with check ((select auth.uid()) = owner_id);
create policy "novanet owners delete subscriptions" on public.novanet_subscriptions for delete to authenticated using ((select auth.uid()) = owner_id);

create index if not exists novanet_subscriptions_token_hash_idx on public.novanet_subscriptions(access_token_hash);
create index if not exists novanet_subscriptions_owner_idx on public.novanet_subscriptions(owner_id);

create or replace function public.novanet_touch_updated_at()
returns trigger language plpgsql as $$
begin new.updated_at = now(); return new; end;
$$;

create trigger novanet_subscriptions_touch before update on public.novanet_subscriptions
for each row execute function public.novanet_touch_updated_at();
