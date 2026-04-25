-- Pro-Link schema
-- Run in Supabase SQL editor (Project > SQL)

create extension if not exists pgcrypto;

create table if not exists users (
  id uuid primary key,
  email text unique not null,
  full_name text not null,
  role text not null check (role in ('admin', 'mentor', 'intern')),
  photo_url text,
  phone text,
  is_approved boolean default false,
  created_at timestamptz default now()
);

create table if not exists departments (
  id uuid primary key default gen_random_uuid(),
  name text not null unique,
  description text,
  created_at timestamptz default now()
);

create table if not exists intern_profiles (
  id uuid primary key default gen_random_uuid(),
  user_id uuid unique not null references users(id) on delete cascade,
  matricule text not null,
  department_id uuid references departments(id),
  mentor_id uuid references users(id),
  university text,
  faculty text,
  start_date date,
  end_date date,
  created_at timestamptz default now()
);

create table if not exists mentor_profiles (
  id uuid primary key default gen_random_uuid(),
  user_id uuid unique not null references users(id) on delete cascade,
  department_id uuid references departments(id),
  specialization text,
  created_at timestamptz default now()
);

create table if not exists schedules (
  id uuid primary key default gen_random_uuid(),
  title text not null,
  file_url text,
  department_id uuid references departments(id),
  uploaded_by uuid references users(id),
  valid_from date,
  valid_to date,
  created_at timestamptz default now()
);

create table if not exists training_modules (
  id uuid primary key default gen_random_uuid(),
  title text not null,
  description text,
  file_url text not null,
  file_type text,
  uploaded_by uuid references users(id),
  department_id uuid references departments(id),
  created_at timestamptz default now()
);

create table if not exists skill_marks (
  id uuid primary key default gen_random_uuid(),
  intern_id uuid references users(id),
  mentor_id uuid references users(id),
  skill_name text not null,
  mark numeric(4,2) check (mark >= 0 and mark <= 20),
  comment text,
  evaluated_at timestamptz default now()
);

create table if not exists attendance (
  id uuid primary key default gen_random_uuid(),
  intern_id uuid references users(id),
  mentor_id uuid references users(id),
  date date not null,
  status text check (status in ('present', 'absent', 'late', 'excused')),
  notes text,
  created_at timestamptz default now()
);

create table if not exists policy_documents (
  id uuid primary key default gen_random_uuid(),
  title text not null,
  file_url text not null,
  uploaded_by uuid references users(id),
  created_at timestamptz default now()
);

insert into departments (name, description)
values
  ('Engineering', 'Software and product engineering'),
  ('IT Support', 'Infrastructure and support'),
  ('Operations', 'Operational management'),
  ('Finance', 'Accounting and finance'),
  ('HR', 'Human resources')
on conflict (name) do nothing;
