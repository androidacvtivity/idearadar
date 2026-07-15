# Flutter Project Setup

## Prerequisites

- Flutter SDK available in the terminal
- Xcode for iOS development
- Android Studio or Android SDK for Android development
- Git authenticated with GitHub

Verify the environment:

```bash
flutter doctor -v
```

## Initialize the project

Clone the repository and generate the Flutter platform files:

```bash
git clone https://github.com/androidacvtivity/idearadar.git
cd idearadar
flutter create --org com.bancusoft --project-name idearadar --platforms=android,ios .
```

The expected application identifiers are:

- Android: `com.bancusoft.idearadar`
- iOS: `com.bancusoft.idearadar`

## Verify the generated project

```bash
flutter pub get
flutter analyze
flutter test
git status
```

## Commit the generated scaffold

Review the generated files before committing:

```bash
git add .
git commit -m "chore: initialize Flutter application"
git push origin main
```

## Next implementation step

After the Flutter scaffold is available on `main`, implement:

1. Application theme
2. English localization infrastructure
3. Idea and status domain models
4. Local SQLite persistence
5. Ideas list and create/edit form
