create extension if not exists pgcrypto;

create table if not exists classes (
  id uuid primary key default gen_random_uuid(),
  code text unique not null,
  teacher_key text not null,
  name text not null,
  status text not null default 'idle',
  current_topic_id uuid
);
create table if not exists tables_ (
  id uuid primary key default gen_random_uuid(),
  class_id uuid not null references classes(id) on delete cascade,
  name text not null
);
create table if not exists students (
  id uuid primary key default gen_random_uuid(),
  class_id uuid not null references classes(id) on delete cascade,
  name text not null,
  table_id uuid references tables_(id) on delete set null
);
create table if not exists thoughts (
  id uuid primary key default gen_random_uuid(),
  class_id uuid not null references classes(id) on delete cascade,
  student_id uuid references students(id) on delete set null,
  table_id uuid references tables_(id) on delete set null,
  text text not null,
  visibility text not null check (visibility in ('now','later','table','private')),
  status text not null default 'captured',
  created_at timestamptz not null default now()
);
create table if not exists queue (
  thought_id uuid primary key references thoughts(id) on delete cascade,
  class_id uuid not null references classes(id) on delete cascade,
  status text not null default 'pending',
  scheduled_for text,
  response text
);

alter table classes enable row level security;
alter table tables_ enable row level security;
alter table students enable row level security;
alter table thoughts enable row level security;
alter table queue enable row level security;

drop policy if exists classes_read on classes;
drop policy if exists classes_write on classes;
create policy classes_read on classes for select using (true);
create policy classes_write on classes for all using (true) with check (true);

drop policy if exists tables_read on tables_;
drop policy if exists tables_write on tables_;
create policy tables_read on tables_ for select using (true);
create policy tables_write on tables_ for all using (true) with check (true);

drop policy if exists students_read on students;
drop policy if exists students_write on students;
create policy students_read on students for select using (true);
create policy students_write on students for all using (true) with check (true);

drop policy if exists thoughts_read on thoughts;
drop policy if exists thoughts_write on thoughts;
create policy thoughts_read on thoughts for select using (true);
create policy thoughts_write on thoughts for all using (true) with check (true);

drop policy if exists queue_read on queue;
drop policy if exists queue_write on queue;
create policy queue_read on queue for select using (true);
create policy queue_write on queue for all using (true) with check (true);

alter table thoughts replica identity full;
alter table classes replica identity full;
alter table students replica identity full;
alter table queue replica identity full;

-- Enable Realtime for the tables used by the app.
alter publication supabase_realtime add table thoughts;
alter publication supabase_realtime add table classes;
alter publication supabase_realtime add table students;
alter publication supabase_realtime add table queue;
