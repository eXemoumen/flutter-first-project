# Pro-Link: Enterprise Internship and Skill Tracking App

Welcome to **Pro-Link**, a modern Flutter application designed for enterprise internship management, skill tracking, and comprehensive professional networking. This application supports various user roles including Admins, Mentors, and Interns, providing tailored experiences and dashboards for each.

## 🚀 Key Features

*   **Role-Based Access Control:** Distinct UI and feature sets for Admins, Mentors, and Interns.
*   **Real-time Database & Auth:** Powered by Supabase for secure, real-time data synchronization and authentication.
*   **State Management:** Built using robust and scalable Riverpod architecture.
*   **Interactive Dashboards:** Featuring data visualization with `fl_chart`.
*   **Push Notifications:** Integrated with Firebase Cloud Messaging (FCM).
*   **Document Generation:** Create and print professional PDF reports on the fly.
*   **Digital Identity:** QR Code generation for Intern IDs and fast check-ins.
*   **Scheduling & Tracking:** Built-in `table_calendar` for managing training sessions and events.

## 🛠️ Technology Stack

*   **Framework:** Flutter (SDK >=3.4.0)
*   **Routing:** GoRouter for deep linking and declarative routing
*   **State Management:** Flutter Riverpod
*   **Backend as a Service (BaaS):** Supabase (Auth, Database, Storage)
*   **Notifications:** Firebase Cloud Messaging
*   **Styling & UI:** Google Fonts, Cupertino Icons, SVG support
*   **Utilities:** Shimmer (Loading effects), Cached Network Image

## 📁 Project Structure

```text
pro_link/
├── android/            # Android native code
├── ios/                # iOS native code
├── lib/
│   ├── config/         # App configurations (e.g., theme.dart, constants)
│   ├── models/         # Data models and entities
│   ├── providers/      # Riverpod state providers
│   ├── screens/        # UI screens (e.g., auth/, intern/, mentor/, admin/)
│   ├── services/       # External API and backend services (Supabase, Firebase)
│   ├── widgets/        # Reusable UI components (e.g., work_id_card.dart)
│   └── main.dart       # Application entry point
├── assets/             # Images, fonts, and static assets
└── pubspec.yaml        # Dependencies and metadata
```

## ⚙️ Setup and Installation Guide

### Prerequisites

Ensure you have the following installed on your machine:
*   [Flutter SDK](https://docs.flutter.dev/get-started/install) (version 3.4.0 or higher)
*   An IDE (VS Code, Android Studio, or IntelliJ IDEA) with Flutter extensions.
*   Git

### Getting Started

1.  **Navigate to the project directory:**
    ```bash
    cd pro_link
    ```

2.  **Install dependencies:**
    ```bash
    flutter pub get
    ```

3.  **Environment Variables & Backend Setup:**
    *   Make sure your Supabase and Firebase configuration keys are properly set up. You may need to add a `.env` file or update the config files in `lib/config/` depending on the project's setup.

### Running the App

*   **To run on Web or Windows:**
    If you haven't enabled web/windows support in this folder yet, generate the platform files first:
    ```bash
    flutter create --platforms=web,windows .
    ```
    Then run the application:
    ```bash
    flutter run -d chrome  # For Web
    flutter run -d windows # For Desktop
    ```

*   **To run on Mobile (Android/iOS):**
    Ensure you have an emulator running or a physical device connected.
    ```bash
    flutter run
    ```

## 🎨 Design and UI/UX

Pro-Link emphasizes a highly professional, enterprise-grade aesthetic. The design system (`lib/config/theme.dart`) leverages modern typography (`google_fonts`), unified color palettes, and responsive layouts to ensure a seamless experience across all devices (Mobile, Web, and Desktop).

---
*Created with ❤️ for seamless professional skill tracking.*
