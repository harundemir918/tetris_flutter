# System Patterns: Tetris Flutter

## Architecture Overview

### Clean Architecture Layers

```
┌─────────────────────────────────────────┐
│               Presentation               │
│  ┌─────────────────────────────────────┐ │
│  │              BLoC                   │ │
│  │  ┌─────────────────────────────────┐│ │
│  │  │            Widgets             ││ │
│  │  └─────────────────────────────────┘│ │
│  └─────────────────────────────────────┘ │
└─────────────────────────────────────────┘
┌─────────────────────────────────────────┐
│               Domain                     │
│  ┌─────────────────────────────────────┐ │
│  │            Use Cases               │ │
│  │  ┌─────────────────────────────────┐│ │
│  │  │            Entities            ││ │
│  │  └─────────────────────────────────┘│ │
│  └─────────────────────────────────────┘ │
└─────────────────────────────────────────┘
┌─────────────────────────────────────────┐
│                Data                      │
│  ┌─────────────────────────────────────┐ │
│  │          Repositories              │ │
│  │  ┌─────────────────────────────────┐│ │
│  │  │         Data Sources           ││ │
│  │  └─────────────────────────────────┘│ │
│  └─────────────────────────────────────┘ │
└─────────────────────────────────────────┘
```

## Key Design Patterns

### 1. BLoC Pattern
- **GameBloc**: Manages overall game state (playing, paused, game over)
- **BoardBloc**: Handles game board state and piece placement
- **ScoreBloc**: Manages scoring and level progression
- **PieceBloc**: Controls active piece movement and rotation

### 2. Repository Pattern
- Abstract repositories in domain layer
- Concrete implementations in data layer
- Facilitates testing and future data source changes

### 3. Use Case Pattern
- Single responsibility principle
- Encapsulates business logic
- Easy to test and maintain

## Core Components

### Domain Layer

#### Entities
```dart
// Core game objects
class Tetromino
class GameBoard  
class GameState
class Score
class Position
```

#### Use Cases
```dart
// Game operations
class StartGameUseCase
class MovePieceUseCase
class RotatePieceUseCase
class ClearLinesUseCase
class UpdateScoreUseCase
class CheckGameOverUseCase
```

#### Repositories (Interfaces)
```dart
abstract class GameRepository
abstract class ScoreRepository
```

### Data Layer

#### Repository Implementations
```dart
class GameRepositoryImpl implements GameRepository
class ScoreRepositoryImpl implements ScoreRepository
```

#### Data Sources
```dart
class LocalGameDataSource
class LocalScoreDataSource
```

### Presentation Layer

#### BLoC Structure
```dart
// Main game coordination
class GameBloc extends Bloc<GameEvent, GameState>

// Board management
class BoardBloc extends Bloc<BoardEvent, BoardState>

// Score tracking
class ScoreBloc extends Bloc<ScoreEvent, ScoreState>

// Piece control
class PieceBloc extends Bloc<PieceEvent, PieceState>
```

#### Widgets
```dart
class GameScreen
class GameBoard
class PiecePreview
class ScoreDisplay
class GameControls
```

## Dependency Injection Structure

### Service Registration
```dart
void setupDependencies() {
  // Data sources
  GetIt.instance.registerLazySingleton<LocalGameDataSource>(
    () => LocalGameDataSource()
  );
  
  // Repositories
  GetIt.instance.registerLazySingleton<GameRepository>(
    () => GameRepositoryImpl(GetIt.instance())
  );
  
  // Use cases
  GetIt.instance.registerLazySingleton<StartGameUseCase>(
    () => StartGameUseCase(GetIt.instance())
  );
  
  // BLoCs
  GetIt.instance.registerFactory<GameBloc>(
    () => GameBloc(GetIt.instance())
  );
}
```

## State Management Flow

### Event Flow
```
User Input → Widget → BLoC Event → Use Case → Repository → Data Source
                  ←        State ←         ←            ←
```

### State Synchronization
- Multiple BLoCs communicate via events
- Domain events for cross-cutting concerns
- Clear separation of responsibilities

## Testing Strategy

### Unit Tests
- Use cases with mocked repositories
- Entity logic validation
- BLoC event/state transitions

### Integration Tests
- Repository implementations
- Full use case flows
- Multi-BLoC interactions

### Widget Tests
- UI component behavior
- User interaction handling
- State-driven UI updates 