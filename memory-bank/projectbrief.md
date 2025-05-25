# Project Brief: Tetris Flutter

## Project Overview
A modern Tetris game implementation using Flutter, designed with Clean Architecture principles, BLoC state management, and dependency injection via get_it.

## Core Requirements

### Functional Requirements
- Classic Tetris gameplay with standard tetromino pieces (I, O, T, S, Z, J, L)
- Real-time piece movement (left, right, down, rotation)
- Line clearing mechanics when rows are completely filled
- Progressive difficulty (increasing fall speed)
- Score tracking system
- Game over detection
- Pause/resume functionality
- Next piece preview
- Hold piece functionality (optional enhancement)

### Technical Requirements
- **Architecture**: Clean Architecture (Domain, Data, Presentation layers)
- **State Management**: BLoC pattern
- **Dependency Injection**: get_it service locator
- **Platform**: Flutter (cross-platform support)
- **Testing**: Unit tests for business logic, widget tests for UI

### Performance Requirements
- Smooth 60fps gameplay
- Responsive controls with minimal input lag
- Efficient rendering of game board updates
- Memory-efficient tetromino management

## Success Criteria
1. Fully playable Tetris game with standard rules
2. Clean, maintainable code following SOLID principles
3. Comprehensive test coverage
4. Smooth user experience across devices
5. Extensible architecture for future enhancements

## Project Scope
- **In Scope**: Core Tetris gameplay, scoring system, difficulty progression
- **Future Enhancements**: Multiplayer, themes, sound effects, leaderboards
- **Out of Scope**: Advanced graphics effects, complex animations

## Technical Stack
- Flutter SDK
- BLoC (flutter_bloc)
- get_it (dependency injection)
- Standard Dart testing framework 