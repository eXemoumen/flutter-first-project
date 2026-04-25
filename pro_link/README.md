# Pro-Link (Flutter + Supabase)

Enterprise internship and skill tracking app with 3 roles:
- Admin
- Mentor
- Intern

## Completed Scope

### Sprint 1
- Corporate UI theme (light/dark)
- Authentication screens (login/register/pending approval)
- Dashboards for all roles
- Digital Work ID card with QR code
- Reusable widget system
- Role-based routing with guarded pages

### Sprint 2
- Admin flows: validate users, assign interns, upload schedules/policies
- Mentor flows: intern group management, marks input, attendance, training upload
- Intern flows: schedules, training modules, marks visualization
- State management wired with Riverpod providers

### Sprint 3
- Supabase bootstrap + configurable backend mode
- Auth service, DB service, storage service with CRUD coverage
- Upload support for avatar/schedule/training/policy files
- SQL schema + RLS + storage policy scripts in `/supabase`

### Sprint 4
- Debounced predictive search with category tabs (interns/modules/policies)
- Responsive layouts for dashboards and forms
- List virtualization via `ListView.builder`

### Sprint 5 (Bonus)
- FCM notification initialization + role topic subscription
- Calendar screen with internship events (`table_calendar`)
- Dark mode persistence (`shared_preferences`)
- Animated stat counters
- PDF export for evaluation report

## Project Structure
- App source: `lib/`
- SQL scripts: `supabase/schema.sql`, `supabase/rls.sql`, `supabase/storage.sql`

## Environment Setup

### 1) Install dependencies
```bash
cd pro_link
flutter pub get
```

### 2) Configure Supabase
Run Flutter with `dart-define` values:
```bash
flutter run \
  --dart-define=SUPABASE_URL=your_supabase_url \
  --dart-define=SUPABASE_ANON_KEY=your_supabase_anon_key
```

If these are missing, the app runs in mock fallback mode.

Mock accounts (password ignored in mock mode):
- `admin@prolink.test`
- `mentor1@prolink.test`
- `intern1@prolink.test`

### 3) Apply SQL scripts
In Supabase SQL editor, execute in order:
1. `supabase/schema.sql`
2. `supabase/rls.sql`
3. `supabase/storage.sql`

### 4) (Optional) Firebase for push notifications
- Add `google-services.json` / platform Firebase configs
- Ensure Firebase project is initialized for Android/iOS

## Verification Commands
```bash
flutter analyze
flutter test
```

## Demo Flow Checklist
- Register intern (pending approval)
- Admin approves intern
- Admin assigns department + mentor
- Mentor uploads module + records attendance + marks skills
- Intern views Work ID, schedule, modules, marks, and calendar
- Search returns matching interns/modules/policies
- Export PDF report from Marks screen
