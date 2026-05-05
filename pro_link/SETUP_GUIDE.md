# Pro-Link Setup Guide

Follow these steps to clone, configure, and run the Pro-Link application on your local machine using Google Chrome.

## 1. Prerequisites

Before you begin, ensure you have the following installed:

- **Git**: [Download Git](https://git-scm.com/downloads)
- **Flutter SDK**: [Install Flutter](https://docs.flutter.dev/get-started/install) (Ensure you are on the `stable` channel)
- **Google Chrome**: Required for running the web version.
- **Visual Studio Code** (Recommended): With the Flutter and Dart extensions.

---

## 2. Clone the Repository

Open your terminal (Command Prompt, PowerShell, or Terminal) and run:

```bash
git clone https://github.com/your-username/pro_link.git
cd pro_link
```

---

## 3. Environment Configuration

The app requires Supabase connection details to function correctly.

1. Locate the `.env.example` file in the root directory.
2. Create a copy named `.env`:

   ```bash
   cp .env.example .env
   ```

3. Open the `.env` file and replace the placeholder values with your **Supabase URL** and **Anon Key**.
    - These can be found in your Supabase Dashboard under `Project Settings > API`.

---

## 4. Install Dependencies

Fetch all necessary packages and plugins:

```bash
flutter pub get
```

---

## 5. Run on Chrome

To launch the application in Google Chrome with the environment variables loaded:

```bash
flutter run -d chrome --dart-define-from-file=.env
```

> [!TIP]
> Using `--dart-define-from-file=.env` automatically passes your Supabase credentials into the app without hardcoding them in the source code.

---

## 6. (Optional) Initialize Backend

If you are setting up a fresh Supabase project, you must apply the SQL scripts located in the `supabase/` directory.

1. Go to the **SQL Editor** in your Supabase Dashboard.
2. Create a new query and paste the contents of these files in order:
   1. `supabase/schema.sql` (Creates tables)
   2. `supabase/rls.sql` (Sets up security policies)
   3. `supabase/storage.sql` (Configures file storage buckets)

---

## Troubleshooting

- **Flutter command not found**: Ensure Flutter is correctly added to your system's `PATH`.
- **Chrome not detected**: Run `flutter doctor` to verify your environment setup.
- **Blank screen on load**: Check the browser console (F12) for errors. This is often due to incorrect Supabase credentials in your `.env` file.
