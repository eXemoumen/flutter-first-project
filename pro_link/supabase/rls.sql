-- Pro-Link Row Level Security policies

alter table users enable row level security;
alter table departments enable row level security;
alter table intern_profiles enable row level security;
alter table mentor_profiles enable row level security;
alter table schedules enable row level security;
alter table training_modules enable row level security;
alter table skill_marks enable row level security;
alter table attendance enable row level security;
alter table policy_documents enable row level security;

create or replace function is_admin(uid uuid)
returns boolean
language sql
stable
as $$
  select exists (
    select 1 from users u
    where u.id = uid and u.role = 'admin' and u.is_approved = true
  );
$$;

-- USERS
create policy users_admin_all
on users
for all
using (is_admin(auth.uid()))
with check (is_admin(auth.uid()));

create policy users_self_select
on users
for select
using (id = auth.uid());

create policy users_self_insert
on users
for insert
with check (id = auth.uid());

create policy users_self_update
on users
for update
using (id = auth.uid())
with check (id = auth.uid());

create policy users_mentor_read_assigned_interns
on users
for select
using (
  role = 'intern'
  and exists (
    select 1 from intern_profiles p
    where p.user_id = users.id and p.mentor_id = auth.uid()
  )
);

-- DEPARTMENTS
create policy departments_authenticated_read
on departments
for select
using (auth.uid() is not null);

create policy departments_admin_write
on departments
for all
using (is_admin(auth.uid()))
with check (is_admin(auth.uid()));

-- INTERN PROFILES
create policy intern_profiles_admin_all
on intern_profiles
for all
using (is_admin(auth.uid()))
with check (is_admin(auth.uid()));

create policy intern_profiles_intern_read_own
on intern_profiles
for select
using (user_id = auth.uid());

create policy intern_profiles_intern_insert_own
on intern_profiles
for insert
with check (user_id = auth.uid());

create policy intern_profiles_mentor_read_assigned
on intern_profiles
for select
using (mentor_id = auth.uid());

-- MENTOR PROFILES
create policy mentor_profiles_admin_all
on mentor_profiles
for all
using (is_admin(auth.uid()))
with check (is_admin(auth.uid()));

create policy mentor_profiles_self_read
on mentor_profiles
for select
using (user_id = auth.uid());

create policy mentor_profiles_self_insert
on mentor_profiles
for insert
with check (user_id = auth.uid());

-- SCHEDULES
create policy schedules_admin_write
on schedules
for all
using (is_admin(auth.uid()))
with check (is_admin(auth.uid()));

create policy schedules_authenticated_read
on schedules
for select
using (auth.uid() is not null);

-- TRAINING MODULES
create policy training_modules_admin_all
on training_modules
for all
using (is_admin(auth.uid()))
with check (is_admin(auth.uid()));

create policy training_modules_mentor_insert
on training_modules
for insert
with check (uploaded_by = auth.uid());

create policy training_modules_authenticated_read
on training_modules
for select
using (auth.uid() is not null);

-- SKILL MARKS
create policy skill_marks_admin_all
on skill_marks
for all
using (is_admin(auth.uid()))
with check (is_admin(auth.uid()));

create policy skill_marks_mentor_insert
on skill_marks
for insert
with check (mentor_id = auth.uid());

create policy skill_marks_intern_read_own
on skill_marks
for select
using (intern_id = auth.uid());

create policy skill_marks_mentor_read_own
on skill_marks
for select
using (mentor_id = auth.uid());

-- ATTENDANCE
create policy attendance_admin_all
on attendance
for all
using (is_admin(auth.uid()))
with check (is_admin(auth.uid()));

create policy attendance_mentor_insert
on attendance
for insert
with check (mentor_id = auth.uid());

create policy attendance_mentor_read_own
on attendance
for select
using (mentor_id = auth.uid());

create policy attendance_intern_read_own
on attendance
for select
using (intern_id = auth.uid());

-- POLICY DOCUMENTS
create policy policy_docs_admin_write
on policy_documents
for all
using (is_admin(auth.uid()))
with check (is_admin(auth.uid()));

create policy policy_docs_authenticated_read
on policy_documents
for select
using (auth.uid() is not null);
