-- SEN SPORT: cloud sync table (run in Supabase SQL Editor)
create table if not exists public.sen_sport_data (
  user_id uuid primary key references auth.users(id) on delete cascade,
  payload jsonb not null default '{}'::jsonb,
  updated_at timestamptz not null default now()
);
alter table public.sen_sport_data enable row level security;
drop policy if exists "read own sen sport data" on public.sen_sport_data;
create policy "read own sen sport data" on public.sen_sport_data for select to authenticated using (auth.uid() = user_id);
drop policy if exists "insert own sen sport data" on public.sen_sport_data;
create policy "insert own sen sport data" on public.sen_sport_data for insert to authenticated with check (auth.uid() = user_id);
drop policy if exists "update own sen sport data" on public.sen_sport_data;
create policy "update own sen sport data" on public.sen_sport_data for update to authenticated using (auth.uid() = user_id) with check (auth.uid() = user_id);
