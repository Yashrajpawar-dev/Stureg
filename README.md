# Stureg — Student Registration App

A Flutter-based student registration and login application powered by **Firebase Authentication** and **Cloud Firestore**. Stureg allows students to create an account, securely sign in, and access their academic profile through a personalized dashboard.

## ✨ Features

- **Splash Screen** — Introductory screen when the application launches.
- **Student Registration** — Register with full name, PRN, email, password, course, and semester.
- **Secure Authentication** — Create accounts and log in using Firebase Authentication.
- **Input Validation** — Validate required fields and confirm passwords during registration.
- **Cloud Database** — Store and retrieve student profile information using Cloud Firestore.
- **Personalized Dashboard** — View student details, including name, PRN, email, course, and semester.
- **Logout** — Sign out of the current account.

## 🛠️ Tech Stack

| Technology | Purpose |
|---|---|
| Flutter | Cross-platform UI development |
| Dart | Application programming language |
| Firebase Authentication | User registration and login |
| Cloud Firestore | Student profile storage |
| Git & GitHub | Version control and project hosting |

## 📱 Application Flow

```text
Splash Screen
      |
      v
  Login Screen
      |
      +-------> Register Screen
      |                |
      |                v
      |          Create Account
      |                |
      +<---------------+
      |
      v
  Authenticate User
      |
      v
   Dashboard
      |
      v
     Logout
```

## 🚀 Getting Started

### Prerequisites

Install the following tools before running the project:

- [Flutter SDK](https://docs.flutter.dev/get-started/install)
- [Dart SDK](https://dart.dev/get-dart) (included with Flutter)
- [Android Studio](https://developer.android.com/studio) or Visual Studio Code
- A configured Firebase project

### 1. Clone the repository

```bash
git clone https://github.com/Yashrajpawar-dev/Stureg.git
cd Stureg
```

### 2. Install dependencies

```bash
flutter pub get
```

### 3. Configure Firebase

Configure the project with your own Firebase project using the [FlutterFire CLI](https://firebase.google.com/docs/flutter/setup).

```bash
flutterfire configure
```

Enable **Email/Password** authentication in Firebase Authentication and create a Cloud Firestore database.

Make sure your Firestore security rules restrict users to accessing only their own profile documents.

### 4. Run the application

Check available devices:

```bash
flutter devices
```

Start the application:

```bash
flutter run
```

## 🗂️ Project Structure

```text
Stureg/
├── lib/
│   ├── main.dart
│   ├── firebase_options.dart
│   ├── login_screen.dart
│   ├── register_screen.dart
│   ├── dashboard_screen.dart
│   └── ...
├── android/
├── ios/
├── web/
├── windows/
├── linux/
├── macos/
├── test/
├── pubspec.yaml
├── pubspec.lock
└── README.md
```

*The files shown inside `lib/` are representative of the application's current structure.*

## 🔐 Security Notes

- User passwords are managed by Firebase Authentication and should never be stored as plain text in Firestore.
- Firestore security rules should enforce authentication and user-specific access.
- Never commit Firebase service-account private keys, API secrets, or other sensitive credentials to a public repository.

## 🎯 Project Objective

Stureg was developed as a learning project to explore Flutter application development, authentication workflows, cloud database integration, and basic student profile management.

## 👨‍💻 Developer

**Yashraj Pawar**

- GitHub: [@Yashrajpawar-dev](https://github.com/Yashrajpawar-dev)

## 📄 License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.
