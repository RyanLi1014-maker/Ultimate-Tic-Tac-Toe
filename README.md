# Ultimate Tic-Tac-Toe

A strategic two-player game built with Godot Engine 4.6, featuring the classic Ultimate Tic-Tac-Toe (also known as Super Tic-Tac-Toe) gameplay.

## 🎮 About the Game

Ultimate Tic-Tac-Toe is an advanced version of the traditional Tic-Tac-Toe game. Instead of a single 3×3 grid, the game consists of nine smaller 3×3 boards arranged in a larger 3×3 grid. This creates a more complex and engaging strategic experience.

### How to Play

1. **Game Structure**: The game board consists of 9 small tic-tac-toe boards arranged in a 3×3 grid (the "big board")
2. **Taking Turns**: Players alternate between placing X and O marks
3. **Movement Rule**: Where you play on a small board determines which small board your opponent must play on next
   - If you place your mark in the top-right cell of any small board, your opponent must play on the top-right small board
4. **Winning Small Boards**: Win a small board by getting three of your marks in a row (horizontally, vertically, or diagonally)
5. **Winning the Game**: Win the entire game by winning three small boards in a row on the big board
6. **Special Cases**: 
   - If sent to a board that's already won or full, you can play on any available board
   - Once a small board is won or full, it becomes disabled

## ✨ Features

- **Strategic Gameplay**: Deep tactical decisions with the unique movement mechanic
- **Two Player Mode**: Local multiplayer for competitive fun
- **Visual Feedback**: Clear indicators showing active/inactive boards
- **Win Detection**: Automatic detection of wins on both small and large boards
- **Clean UI**: Intuitive interface with smooth animations
- **Mobile Optimized**: Designed to work well on mobile devices

## 🛠️ Technical Details

### Built With

- **Godot Engine 4.6** - Game engine
- **GDScript** - Programming language
- **Rendering Method**: Mobile-optimized renderer

### Project Structure

```
Ultimate-Tic-Tac-Toe/
├── scene/
│   ├── chessboard/          # Chessboard-related scenes
│   ├── main_menu.tscn       # Main menu scene
│   └── ultimate_tic_tac_toe_game.tscn  # Main game scene
├── script/
│   ├── big_chessboard.gd    # Logic for the 3×3 big board
│   ├── small_chessboard.gd  # Logic for individual small boards
│   ├── cell.gd              # Individual cell behavior
│   ├── global.gd            # Global game state management
│   ├── main_menu.gd         # Main menu controller
│   └── ultimate_tic_tac_toe_game.gd  # Game controller
├── asset/
│   └── image/               # Game assets and textures
├── project.godot            # Godot project configuration
└── README.md                # This file
```

### Key Components

- **BigChessboard**: Manages the 3×3 grid of small boards and checks for overall game victory
- **SmallChessboard**: Handles individual 3×3 boards, tracks occupancy, and detects local wins
- **Cell**: Represents individual playable cells with player assignment and visual feedback
- **Global**: Singleton managing current player state and turn switching

## 📥 Installation

### Option 1: Download Pre-built Binary (Recommended)

1. Visit the [Releases page](../../releases) of this repository
2. Download the latest release for your platform:
   - **Windows**: Download the `.exe` file or `.zip` archive
   - **Linux**: Download the Linux build
   - **macOS**: Download the macOS build
3. Extract the archive (if applicable)
4. Run the executable file to start the game

### Option 2: Build from Source

#### Prerequisites

- [Godot Engine 4.6](https://godotengine.org/download/) or later

#### Setup Instructions

1. Clone or download this repository:
   ```bash
   git clone <repository-url>
   cd Ultimate-Tic-Tac-Toe
   ```

2. Open the project in Godot Engine:
   - Launch Godot Engine
   - Click "Import" button
   - Navigate to the project folder and select `project.godot`
   - Click "Import & Edit"

3. Run the game:
   - Press F5 or click the "Play Scene" button in Godot
   - The game will start at the main menu

4. (Optional) Export the game:
   - Go to `Project > Export`
   - Configure export settings for your target platform
   - Click "Export Project" to create a standalone executable

## 🎯 How to Play

1. Start the game from the main menu
2. Player 1 (X) goes first
3. Click on any cell in any active small board to place your mark
4. Your opponent (O) must play on the small board corresponding to where you placed your mark
5. Continue alternating turns following the movement rules
6. Win small boards to claim them on the big board
7. First player to win three small boards in a row wins the game!

### Controls

- **Mouse/Touch**: Click/tap cells to place marks
- **ESC**: Exit the game/return to menu

## 🎨 Assets

The game includes custom textures and animations for:
- Enabled/disabled board states
- X and O piece animations
- Visual indicators for game state

## 🤝 Contributing

Contributions are welcome! Feel free to:
- Report bugs
- Suggest new features
- Submit pull requests
- Improve documentation

## 📄 License

This project is open source and available under the MIT License.

## 🙏 Acknowledgments

- Built with [Godot Engine](https://godotengine.org/)
- Inspired by the classic Ultimate Tic-Tac-Toe game concept

---

**Enjoy the game!** 🎮
