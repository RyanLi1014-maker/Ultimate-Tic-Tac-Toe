# The 3×3 outer board that manages the flow of Ultimate Tic-Tac-Toe.
# Tracks which small board is active and detects big-board wins.
extends TextureRect
class_name BigChessboard

const BOARD_SPACING := 88 # Pixel distance between small boards in the scene layout

var small_chessboards := [[], [], []] # 3×3 grid of SmallChessboard references

signal win(winner: String)


func _ready() -> void:
    # Build the 2D grid from the scene hierarchy and connect signals
    for r in $VBoxContainer.get_children():
        for c in r.get_children():
            small_chessboards[r.get_index()].append(c)
            c.small_chessboard_occupied.connect(_on_small_chessboard_occupied)
            # Forward all cell signals to this handler for target-board logic
            for sub_r in c.cells:
                for sub_c in sub_r:
                    sub_c.cell_occupied.connect(_on_cell_occupied)


# Called when a small board is won or tied — checks for a big-board win.
func _on_small_chessboard_occupied(_small_chessboard_position: Vector2) -> void:
    var winner = check_winner()
    if winner:
        win.emit(winner)


# Called when any cell is pressed.
# Enables the targeted small board (whose grid position matches the cell)
# And disables all others. If the target is full or already won, all boards
# End up disabled — _reopen_if_all_disabled re-enables them (free-move rule).
func _on_cell_occupied(cell_position: Vector2) -> void:
    for r in small_chessboards:
        for c in r:
            if _board_grid_position(c) == cell_position:
                c.disabled = false
            else:
                c.disabled = true
    _reopen_if_all_disabled()


# Returns the grid coordinate (0–2, 0–2) of a small board based on its position
# In the scene layout.
func _board_grid_position(board: SmallChessboard) -> Vector2:
    return Vector2(
        board.position.x / BOARD_SPACING,
        board.get_parent().position.y / BOARD_SPACING
    )


# If every small board is disabled (the targeted board is full or won),
# Re-enable all so the player can play anywhere (Ultimate Tic-Tac-Toe free-move rule).
func _reopen_if_all_disabled() -> void:
    for r in small_chessboards:
        for c in r:
            if not c.disabled:
                return
    for r in small_chessboards:
        for c in r:
            c.disabled = false


# Checks the big-board 3×3 for a win (rows, columns, diagonals).
# Returns "X", "O", or "" (no winner).
func check_winner() -> String:
    var occupiers: Array = [[], [], []]
    for r in small_chessboards.size():
        for c in small_chessboards[r]:
            occupiers[r].append(c.occupier)

    # Rows
    for i in 3:
        if _three_equal(occupiers[i][0], occupiers[i][1], occupiers[i][2]):
            return occupiers[i][0]

    # Columns
    for j in 3:
        if _three_equal(occupiers[0][j], occupiers[1][j], occupiers[2][j]):
            return occupiers[0][j]

    # Diagonals
    if _three_equal(occupiers[0][0], occupiers[1][1], occupiers[2][2]):
        return occupiers[0][0]
    if _three_equal(occupiers[0][2], occupiers[1][1], occupiers[2][0]):
        return occupiers[0][2]

    return ""


# Returns true if all three strings are non-empty and equal.
static func _three_equal(a: String, b: String, c: String) -> bool:
    return not a.is_empty() and a == b and b == c
