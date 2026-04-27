# Translator App

A Flutter translator app with Firebase Cloud Firestore history.

## Main features

- Translate text between several languages
- Auto-detect source language
- Save translation history to Firebase Cloud Firestore
- View saved translations in a list
- Delete saved translations from the cloud history

## MVC-like structure

```text
lib/
├── models/
│   ├── translation.dart
│   └── translation_result.dart
├── controllers/
│   ├── translation_controller.dart
│   └── history_controller.dart
├── services/
│   ├── translation_service.dart
│   └── firebase_service.dart
└── views/
    ├── screens/
    │   ├── translator_screen.dart
    │   └── history_screen.dart
    └── widgets/
        ├── message_box.dart
        └── translation_card.dart
```

### Model

The model classes store the app data structure only.

- `Translation` represents one translation record.
- `TranslationResult` represents success or failure from the translation service.

### View

The view layer contains screens and widgets only.

- `TranslatorScreen` displays the translation form and result.
- `HistoryScreen` displays saved translations.
- Widgets such as `MessageBox` and `TranslationCard` handle UI display only.

### Controller

The controller layer connects the view with services.

- `TranslationController` handles translation, language selection, swap, clear, loading state, and saving to Firebase.
- `HistoryController` handles getting and deleting translation history.

### Services

The service layer handles external operations.

- `TranslationService` communicates with the translation package.
- `FirebaseService` communicates with Cloud Firestore.

## How to run

```bash
flutter clean
flutter pub get
flutter run
```

## Stability and performance improvements

- Translation requests use a timeout, so the app does not wait forever when the internet is slow.
- Firebase write/delete operations use a timeout and return a clear error instead of crashing.
- Repeated translations are cached during the app session, so translating the same text again is faster.
- The translate button is disabled while a translation is running, preventing duplicate requests.
- Old translation responses are ignored if the screen is closed or a newer request starts.
- History loading is limited to the latest 50 translations to keep the list smooth.
- Text input is limited to 700 characters to avoid very slow API requests.
