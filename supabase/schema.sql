-- SEN SPORT / Supabase schema
-- Run in Supabase SQL Editor. Roles are assigned by trusted admin only.
create extension if not exists pgcrypto;
create table if not exists public.teams(id uuid primary key default gen_random_uuid(),name text not null,created_at timestamptz default now());
create table if not exists public.profiles(id uuid primary key references auth.users(id) on delete cascade,team_id uuid references public.teams(id),full_name text not null,role text not null default 'player' check(role in ('coach','player')),created_at timestamptz default now());
create table if not exists public.players(id uuid primary key default gen_random_uuid(),team_id uuid not null references public.teams(id) on delete cascade,user_id uuid references auth.users(id) on delete set null,name text not null,jersey_number int,photo_path text,created_at timestamptz default now());
create table if not exists public.sessions(id uuid primary key default gen_random_uuid(),team_id uuid not null references public.teams(id) on delete cascade,title text not null,session_date date not null,notes text,created_at timestamptz default now());
create table if not exists public.attendance(id uuid primary key default gen_random_uuid(),session_id uuid not null references public.sessions(id) on delete cascade,player_id uuid not null references public.players(id) on delete cascade,status text not null check(status in ('present','absent','late')),unique(session_id,player_id));
create table if not exists public.fees(id uuid primary key default gen_random_uuid(),team_id uuid not null references public.teams(id) on delete cascade,player_id uuid not null references public.players(id) on delete cascade,period text not null,amount numeric(12,2) not null check(amount>=0),status text not null default 'pending' check(status in ('pending','approved','rejected')),receipt_path text,approved_by uuid references auth.users(id),approved_at timestamptz,created_at timestamptz default now());
create table if not exists public.performance_reports(id uuid primary key default gen_random_uuid(),team_id uuid not null references public.teams(id) on delete cascade,player_id uuid not null references public.players(id) on delete cascade,report_date date not null default current_date,title text not null,body text not null,created_by uuid references auth.users(id),created_at timestamptz default now());
create table if not exists public.messages(id uuid primary key default gen_random_uuid(),team_id uuid not null references public.teams(id) on delete cascade,sender_id uuid not null references auth.users(id),recipient_id uuid references auth.users(id),body text not null,created_at timestamptz default now());
create table if not exists public.media(id uuid primary key default gen_random_uuid(),team_id uuid not null references public.teams(id) on delete cascade,player_id uuid references public.players(id) on delete cascade,title text not null,storage_path text not null,created_by uuid references auth.users(id),created_at timestamptz default now());
create or replace function public.is_team_coach(tid uuid) returns boolean language sql stable security definer set search_path=public as $$ select exists(select 1 from profiles where id=auth.uid() and team_id=tid and role='coach') $$;
create or replace function public.is_team_member(tid uuid) returns boolean language sql stable security definer set search_path=public as $$ select exists(select 1 from profiles where id=auth.uid() and team_id=tid) $$;
alter table public.teams enable row level security;
alter table public.profiles enable row level security;
alter table public.players enable row level security;
alter table public.sessions enable row level security;
alter table public.attendance enable row level security;
alter table public.fees enable row level security;
alter table public.performance_reports enable row level security;
alter table public.messages enable row level security;
alter table public.media enable row level security;
create policy team_member_read on teams for select using(is_team_member(id));
create policy profile_read_team on profiles for select using(team_id is not null and is_team_member(team_id));
create policy profile_self_update on profiles for update using(id=auth.uid()) with check(id=auth.uid());
create policy players_team_read on players for select using(is_team_member(team_id));
create policy players_coach_manage on players for all using(is_team_coach(team_id)) with check(is_team_coach(team_id));
create policy sessions_team_read on sessions for select using(is_team_member(team_id));
create policy sessions_coach_manage on sessions for all using(is_team_coach(team_id)) with check(is_team_coach(team_id));
create policy attendance_team_read on attendance for select using(exists(select 1 from sessions s where s.id=session_id and is_team_member(s.team_id)));
create policy attendance_coach_manage on attendance for all using(exists(select 1 from sessions s where s.id=session_id and is_team_coach(s.team_id))) with check(exists(select 1 from sessions s where s.id=session_id and is_team_coach(s.team_id)));
create policy fees_team_read on fees for select using(is_team_member(team_id));
create policy fees_player_insert on fees for insert with check(is_team_member(team_id) and exists(select 1 from players p where p.id=player_id and p.user_id=auth.uid()));
create policy fees_coach_update on fees for update using(is_team_coach(team_id)) with check(is_team_coach(team_id));
create policy reports_team_read on performance_reports for select using(is_team_member(team_id));
create policy reports_coach_manage on performance_reports for all using(is_team_coach(team_id)) with check(is_team_coach(team_id));
create policy messages_team_read on messages for select using(is_team_member(team_id) and (recipient_id is null or recipient_id=auth.uid() or sender_id=auth.uid()));
create policy messages_member_send on messages for insert with check(is_team_member(team_id) and sender_id=auth.uid());
create policy media_team_read on media for select using(is_team_member(team_id));
create policy media_coach_manage on media for all using(is_team_coach(team_id)) with check(is_team_coach(team_id));
-- IMPORTANT: create first coach/profile and team using trusted Supabase dashboard/admin process.
-- Never expose service_role key in browser code.