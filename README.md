# BitePlate — Smart Restaurant Management System (SRMS)

A prototype restaurant management system: a **Dart backend** (REST API + domain logic)
and a **Flutter web frontend** (point-of-sale UI).

## Architecture

```
biteplate/
├── backend/                 # Dart REST API + domain + design patterns
│   ├── bin/
│   │   ├── server.dart      # HTTP server entry point (port 8080)
│   │   └── demo.dart        # pure-Dart console walkthrough (no Flutter needed)
│   ├── lib/
│   │   ├── biteplate_backend.dart      # public barrel
│   │   └── src/
│   │       ├── domain/      # menu, order, table, staff, bill
│   │       ├── patterns/    # factory, decorator, strategy, command, observer, singleton
│   │       ├── services/    # kitchen_service, billing_facade, restaurant_service
│   │       └── api/         # server.dart (shelf routes)
│   └── test/                # unit tests
├── frontend/                # Flutter web app (POS UI)
│   └── lib/
│       ├── main.dart        # app shell + navigation
│       ├── api_client.dart  # HTTP client
│       ├── app_state.dart   # ChangeNotifier state
│       ├── models.dart      # DTOs
│       ├── theme.dart       # UI theme
│       └── screens/         # floor, order, kitchen, billing, reports
└── docs/                    # UML diagrams (png + PlantUML source)
```

## How to run

> Requires the Flutter SDK (which bundles Dart). Check with `flutter --version` and `dart --version`.

### Backend (terminal 1)

```bash
cd backend
dart pub get
dart run bin/server.dart
# → BitePlate backend running on http://0.0.0.0:8080
```

### Frontend (terminal 2)

```bash
cd frontend
flutter pub get
flutter run -d chrome
```

Use the left navigation rail: **Floor → Order → Kitchen → Billing → Reports**.

### Console demo (no Flutter required)

```bash
cd backend
dart pub get
dart run bin/demo.dart
```

### Tests

```bash
cd backend
dart test
```
