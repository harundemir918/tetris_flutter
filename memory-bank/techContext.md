# Technical Context: Tetris Flutter

## Technology Stack

### Core Framework
- **Flutter SDK**: Latest stable version
- **Dart**: Language for all application logic
- **Material Design**: UI components and theming

### State Management
- **flutter_bloc**: ^8.1.3
  - Predictable state management
  - Separation of business logic from UI
  - Easy testing with clear event/state flow

### Dependency Injection
- **get_it**: ^7.6.4
  - Service locator pattern
  - Lazy loading of dependencies
  - Singleton and factory registrations

### Development Dependencies
- **flutter_test**: Testing framework
- **bloc_test**: ^9.1.4 - BLoC testing utilities
- **mockito**: ^5.4.2 - Mocking for unit tests
- **build_runner**: ^2.4.7 - Code generation

## Project Structure

```
lib/
├── main.dart                 # App entry point
├── core/                     # Shared utilities
│   ├── di/                   # Dependency injection
│   ├── constants/            # App constants
│   ├── utils/                # Helper functions
│   └── exceptions/           # Custom exceptions
├── domain/                   # Business logic layer
│   ├── entities/             # Core business objects
│   ├── repositories/         # Repository interfaces
│   └── usecases/             # Business logic operations
├── data/                     # Data layer
│   ├── repositories/         # Repository implementations
│   ├── datasources/          # Data sources (local/remote)
│   └── models/               # Data models
└── presentation/             # UI layer
    ├── blocs/                # State management
    ├── pages/                # Screen widgets
    ├── widgets/              # Reusable UI components
    └── theme/                # App theming
```

## Development Setup

### Prerequisites
- Flutter SDK (latest stable)
- Dart SDK (included with Flutter)
- IDE: VS Code or Android Studio
- Platform-specific requirements (Android SDK, Xcode for iOS)

### Installation Steps
1. Clone repository
2. Run `flutter pub get` to install dependencies
3. Run `flutter pub run build_runner build` for code generation
4. Run `flutter run` to start development

### Build Configuration
- **Debug**: Development with hot reload
- **Release**: Optimized for production
- **Profile**: Performance analysis mode

## Performance Considerations

### Game Loop Optimization
- **Flutter's scheduler**: Leverages 60fps rendering pipeline
- **Efficient redraws**: Only update changed board cells
- **State immutability**: Prevents unnecessary rebuilds

### Memory Management
- **Object pooling**: Reuse tetromino instances
- **Efficient collections**: Use appropriate data structures
- **Widget lifecycle**: Proper disposal of resources

### Input Responsiveness
- **Gesture detection**: Immediate response to user input
- **State updates**: Minimal processing in UI thread
- **Animation performance**: Smooth piece movements

## Testing Strategy

### Unit Tests
```dart
test/
├── domain/
│   ├── entities/            # Entity logic tests
│   └── usecases/            # Use case tests
├── data/
│   └── repositories/        # Repository tests
└── presentation/
    └── blocs/               # BLoC tests
```

### Test Configuration
- **Mocking**: Repository and data source mocking
- **BLoC testing**: Event/state verification
- **Golden tests**: UI consistency verification

## Build & Deployment

### Platform Targets
- **Android**: API 21+ (Android 5.0)
- **iOS**: iOS 11.0+
- **Web**: Modern browsers (Chrome, Safari, Firefox)
- **Desktop**: Windows, macOS, Linux (optional)

### Build Commands
```bash
# Debug build
flutter run

# Release build
flutter build apk --release
flutter build ios --release
flutter build web --release
```

## Development Tools

### Code Quality
- **Analysis options**: Strict linting rules
- **Formatter**: Dart formatter for consistent style
- **Import organization**: Automatic import sorting

### Debugging
- **Flutter Inspector**: Widget tree analysis
- **Performance overlay**: Frame timing analysis
- **Debug prints**: Strategic logging for game state

## Dependencies Management

### Core Dependencies
```yaml
dependencies:
  flutter:
    sdk: flutter
  flutter_bloc: ^8.1.3
  get_it: ^7.6.4
  equatable: ^2.0.5

dev_dependencies:
  flutter_test:
    sdk: flutter
  bloc_test: ^9.1.4
  mockito: ^5.4.2
  build_runner: ^2.4.7
```

### Version Pinning
- Pin major versions for stability
- Regular dependency updates
- Security vulnerability monitoring 