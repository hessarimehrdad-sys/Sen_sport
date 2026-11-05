-- SEN SPORT: Supabase backend schema
-- Run in Supabase Dashboard > SQL Editor. Auth users sign up first.
create extension if not exists pgcrypto;

create table if not exists public.teams (
 id uuid primary key default gen_random_uuid(),
 name text not null,
 created_by uuid not null references auth.users(id) on delete cascade,
 created_at timestamptz not null default now()
);
create table if not exists public.team_members (
 team_id uuid not null references public.teams(id) on delete cascade,
 user_id uuid not null references auth.users(id) on delete cascade,
 role text not null check (role in ('coach','player')),
 joined_at timestamptz not null default now(),
 primary key(team_id,user_id)
);
create table if not exists public.players (
 id uuid primary key default gen_random_uuid(),
 team_id uuid not null references public.teams(id) on delete cascade,
 name text not null,
 jersey_number integer,
 photo_url text,
 linked_user_id uuid references auth.users(id) on delete set null,
 created_at timestamptz not null default now()
);
create table if not exists public.attendance (
 id uuid primary key default gen_random_uuid(),
 team_id uuid not null references public.teams(id) on delete cascade,
 player_id uuid not null references public.players(id) on delete cascade,
 attendance_date date not null,
 status text not null check(status in ('حاضر','غایب','تأخیر')),
 created_by uuid not null references auth.users(id),
 unique(player_id,attendance_date)
);
create table if not exists public.fees (
 id uuid primary key default gen_random_uuid(),
 team_id uuid not null references public.teams(id) on delete cascade,
 player_id uuid not null references public.players(id) on delete cascade,
 month_label text not null,
 amount bigint not null check(amount>=0),
 approved boolean not null default false,
 created_by uuid not null references auth.users(id),
 created_at timestamptz not null default now()
);
create table if not exists public.player_records (
 id uuid primary key default gen_random_uuid(),
 team_id uuid not null references public.teams(id) on delete cascade,
 player_id uuid not null references public.players(id) on delete cascade,
 category text not null check(category in ('plan','message','performance','video','match')),
 title text,
 body text,
 created_by uuid not null references auth.users(id),
 created_at timestamptz not null default now()
);

create or replace function public.is_team_member(tid uuid)
returns boolean language sql stable security definer set search_path=public
as $$ select exists(select 1 from public.team_members m where m.team_id=tid and m.user_id=auth.uid()); $$;
create or replace function public.is_team_coach(tid uuid)
returns boolean language sql stable security definer set search_path=public
as $$ select exists(select 1 from public.team_members m where m.team_id=tid and m.user_id=auth.uid() and m.role='coach'); $$;

alter table public.teams enable row level security;
alter table public.team_members enable row level security;
alter table public.players enable row level security;
alter table public.attendance enable row level security;
alter table public.fees enable row level security;
alter table public.player_records enable row level security;

drop policy if exists "team members read teams" on public.teams;
create policy "team members read teams" on public.teams for select using (public.is_team_member(id) or created_by=auth.uid());
drop policy if exists "authenticated create team" on public.teams;
create policy "authenticated create team" on public.teams for insert to authenticated with check(created_by=auth.uid());
drop policy if exists "coach update team" on public.teams;
create policy "coach update team" on public.teams for update using(public.is_team_coach(id)) with check(public.is_team_coach(id));

drop policy if exists "members read membership" on public.team_members;
create policy "members read membership" on public.team_members for select using(public.is_team_member(team_id) or user_id=auth.uid());
drop policy if exists "coach manage membership" on public.team_members;
create policy "coach manage membership" on public.team_members for all using(public.is_team_coach(team_id)) with check(public.is_team_coach(team_id));
-- The team creator can add their first coach membership:
drop policy if exists "creator add self coach" on public.team_members;
create policy "creator add self coach" on public.team_members for insert to authenticated with check(user_id=auth.uid() and role='coach' and exists(select 1 from public.teams t where t.id=team_id and t.created_by=auth.uid()));

do $$ declare t text; begin
 foreach t in array array['players','attendance','fees','player_records'] loop
  execute format('drop policy if exists "team read %1$s" on public.%1$s',t);
  execute format('create policy "team read %1$s" on public.%1$s for select using(public.is_team_member(team_id))',t);
  execute format('drop policy if exists "coach write %1$s" on public.%1$s',t);
  execute format('create policy "coach write %1$s" on public.%1$s for all using(public.is_team_coach(team_id)) with check(public.is_team_coach(team_id))',t);
 end loop;
end $$;
-- Players can read their own linked profile and records; coach-only writes stay protected.
drop policy if exists "player own profile" on public.players;
create policy "player own profile" on public.players for select using(linked_user_id=auth.uid());
drop policy if exists "player own records" on public.player_records;
create policy "player own records" on public.player_records for select using(player_id in(select id from public.players where linked_user_id=auth.uid()));
drop policy if exists "player own attendance" on public.attendance;
create policy "player own attendance" on public.attendance for select using(player_id in(select id from public.players where linked_user_id=auth.uid()));
drop policy if exists "player own fees" on public.fees;
create policy "player own fees" on public.fees for select using(player_id in(select id from public.players where linked_user_id=auth.uid()));
