# Product Context: Tetris Flutter

## Why This Project Exists

### Problem Statement
- Need for a well-architected, educational Tetris implementation showcasing Flutter best practices
- Demonstration of Clean Architecture and BLoC pattern in a real-world game scenario
- Providing a foundation for learning game development patterns in Flutter

### Target Audience
- Flutter developers learning Clean Architecture
- Game development enthusiasts
- Mobile users seeking classic puzzle games
- Developers studying state management patterns

## How It Should Work

### User Experience Goals
- **Intuitive**: Familiar Tetris controls that feel natural
- **Responsive**: Immediate feedback to user input
- **Progressive**: Gradual difficulty increase maintains engagement
- **Clear**: Visual feedback for all game states and actions

### Core User Journey
1. **Game Start**: User launches app → sees game board → can start playing immediately
2. **Gameplay Loop**: 
   - Tetromino falls automatically
   - User controls piece movement and rotation
   - Lines clear when complete
   - Score increases with successful clears
   - Speed increases progressively
3. **Game End**: Clear game over state → option to restart

### Key User Interactions
- **Touch Controls**: Tap/swipe gestures for piece movement
- **Visual Feedback**: Clear indication of active piece, next piece, score
- **State Management**: Pause/resume without losing progress
- **Performance**: Smooth animations and immediate response

## Game Mechanics

### Standard Tetris Rules
- 7 tetromino types with standard shapes and colors
- 10-wide × 20-high game board
- Piece spawns at top center
- Gravity pulls pieces down
- Player can move left/right, rotate, soft drop
- Complete horizontal lines disappear
- Game ends when pieces reach the top

### Scoring System
- Points for line clears (more points for multiple lines)
- Bonus points for soft drops
- Progressive difficulty increases score multiplier

### Visual Design
- Clean, modern interface
- Clear distinction between filled and empty cells
- Next piece preview area
- Score and level display
- Pause indicator

## Success Metrics
- Smooth gameplay at 60fps
- Responsive controls (< 50ms input lag)
- Intuitive user interface
- Engaging progression system 