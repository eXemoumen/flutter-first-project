-- Storage buckets and policies (run after schema + RLS)

insert into storage.buckets (id, name, public)
values
  ('avatars', 'avatars', true),
  ('schedules', 'schedules', true),
  ('training', 'training', true),
  ('policies', 'policies', true)
on conflict (id) do nothing;

-- Public read access for file URLs used in app
create policy "Public read avatars"
on storage.objects for select
using (bucket_id = 'avatars');

create policy "Public read schedules"
on storage.objects for select
using (bucket_id = 'schedules');

create policy "Public read training"
on storage.objects for select
using (bucket_id = 'training');

create policy "Public read policies"
on storage.objects for select
using (bucket_id = 'policies');

-- Authenticated upload by folder ownership convention
create policy "Authenticated upload avatars"
on storage.objects for insert
with check (bucket_id = 'avatars' and auth.uid() is not null);

create policy "Authenticated upload schedules"
on storage.objects for insert
with check (bucket_id = 'schedules' and auth.uid() is not null);

create policy "Authenticated upload training"
on storage.objects for insert
with check (bucket_id = 'training' and auth.uid() is not null);

create policy "Authenticated upload policies"
on storage.objects for insert
with check (bucket_id = 'policies' and auth.uid() is not null);
