# The 3×3 outer board that manages the flow of Ultimate Tic-Tac-Toe.
# Tracks which small board is active and detects big-board wins.
extends TextureRect
class_name BigChessboard

const BOARD_SPACING := 88 # Pixel distance between small boards in the scene layout

@onready var game = get_tree().current_scene

var small_chessboards := [[], [], []] # 3×3 grid of SmallChessboard references
var _board_grid_map: Dictionary = {} # Maps SmallChessboard → its grid position (pre-computed)

signal win(winner: String)


func _ready() -> void:
    # Build the 2D grid from the scene hierarchy, pre-compute grid positions,
    # and connect signals.
    var rows := $VBoxContainer.get_children()
    for r_idx in rows.size():
        var row := rows[r_idx]
        var col_nodes := row.get_children()
        for c_idx in col_nodes.size():
            var board: SmallChessboard = col_nodes[c_idx]
            small_chessboards[r_idx].append(board)
            # Pre-compute grid position so _on_cell_occupied doesn't re-divide
            _board_grid_map[board] = Vector2(c_idx, r_idx)
            board.small_chessboard_occupied.connect(_on_small_chessboard_occupied)
            # Forward all cell signals to this handler for target-board logic
            for board_r in board.cells:
                for cell in board_r:
                    cell.cell_occupied.connect(_on_cell_occupied)


# Called when a small board is won or tied — checks for a big-board win.
func _on_small_chessboard_occupied(small_chessboard_position: Vector2) -> void:
    var board_occupier: String = small_chessboards \
    [small_chessboard_position.y] \
    [small_chessboard_position.x].occupier
    if game.game_mode == "Quick" and board_occupier:
        win.emit(board_occupier)
        return
    # Check for a win — the last move of a win must occupy a small board
    var winner := check_winner()
    if winner:
        win.emit(winner)


# Called when any cell is pressed.
# Enables the targeted small board (whose grid position matches the cell)
# and disables all others. If the target is full or already won, all boards
# end up disabled — _reopen_if_all_disabled re-enables them (free-move rule).
func _on_cell_occupied(cell_position: Vector2) -> void:
    var all_disabled := true
    for r in small_chessboards:
        for c in r:
            if _board_grid_map.get(c, Vector2(-1, -1)) == cell_position:
                c.disabled = false
            else:
                c.disabled = true
            if not c.disabled:
                all_disabled = false
    # If every board ended up disabled, re-enable all (free-move rule)
    if all_disabled:
        for r in small_chessboards:
            for c in r:
                c.disabled = false
    # Check for a draw — the last move of a draw does not necessarily occupy a small board
    elif check_draw():
        win.emit("")


func check_draw() -> bool:
    for r in small_chessboards:
        for c in r:
            if c.occupier.is_empty() and not c.is_full():
                return false
    return true


# Checks the big-board 3×3 for a win (rows, columns, diagonals).
# Accesses boards directly to avoid allocating an intermediate occupiers array.
# Returns "X", "O", or "" (no winner).
func check_winner() -> String:
    # Rows
    for i in 3:
        var a: String = small_chessboards[i][0].occupier
        var b: String = small_chessboards[i][1].occupier
        var c: String = small_chessboards[i][2].occupier
        if _three_equal(a, b, c):
            return a

    # Columns
    for j in 3:
        var a: String = small_chessboards[0][j].occupier
        var b: String = small_chessboards[1][j].occupier
        var c: String = small_chessboards[2][j].occupier
        if _three_equal(a, b, c):
            return a

    # Diagonals
    if _three_equal(
        small_chessboards[0][0].occupier,
        small_chessboards[1][1].occupier,
        small_chessboards[2][2].occupier
    ):
        return small_chessboards[0][0].occupier
    if _three_equal(
        small_chessboards[0][2].occupier,
        small_chessboards[1][1].occupier,
        small_chessboards[2][0].occupier
    ):
        return small_chessboards[0][2].occupier

    return ""


# Returns true if all three strings are non-empty and equal.
static func _three_equal(a: String, b: String, c: String) -> bool:
    return not a.is_empty() and a == b and b == c
