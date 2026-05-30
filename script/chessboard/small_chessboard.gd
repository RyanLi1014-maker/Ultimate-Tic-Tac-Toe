# A single 3×3 small board within the larger Ultimate Tic-Tac-Toe grid.
# Manages its 9 child cells, detects wins/ties, and updates its visual
# State (enabled/disabled texture + winner icon) whenever the disabled property changes.
extends TextureRect
class_name SmallChessboard

const BOARD_SPACING := 88 # Pixel distance between boards in the big-board layout

var disabled := false:
    set(value):
        if disabled == value:
            return
        disabled = value
        _refresh()

var occupier: String = "" # "X" or "O" once won; "" if undecided

var cells: Array = [[], [], []] # 3×3 grid of Cell references

var state_textures: Array = [
    preload("res://asset/image/texture/chessboard/small_chessboard_disable.png"),
    preload("res://asset/image/texture/chessboard/small_chessboard_enable.png")
]

signal small_chessboard_occupied(grid_position: Vector2) # This board's position in the big board


func _ready() -> void:
    # Build the 2D cell grid from the scene hierarchy and connect signals
    for r in $VBoxContainer.get_children():
        for c in r.get_children():
            cells[r.get_index()].append(c)
            c.cell_occupied.connect(_on_cell_occupied)
    _refresh()


# Called when a cell inside this board is pressed.
# Checks for a winner — if found, marks the board as won and plays the
# Winner icon animation. If the board is full with no winner, marks it tied.
func _on_cell_occupied(_cell_grid_position: Vector2) -> void:
    var winner = check_winner()
    if winner:
        occupier = winner
        disabled = true
        match winner:
            "X":
                $Icon_X.visible = true
                $Icon_X.play("appear")
            "O":
                $Icon_O.visible = true
                $Icon_O.play("appear")
        small_chessboard_occupied.emit(
            Vector2(position.x / BOARD_SPACING, get_parent().position.y / BOARD_SPACING)
        )
    elif is_full():
        disabled = true


# Returns true if all 9 cells are occupied (draw).
func is_full() -> bool:
    for r in cells:
        for c in r:
            if not c.occupier:
                return false
    return true


# Checks this board's 3×3 for a win (rows, columns, diagonals).
# Returns "X", "O", or "" (no winner).
func check_winner() -> String:
    var occupiers: Array = [[], [], []]
    for r in cells.size():
        for c in cells[r]:
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


# Applies the current disabled state to the board's texture and all child cells.
# If re-enabling but the board is full or won, it re-disables itself.
func _refresh() -> void:
    if disabled:
        texture = state_textures[0]
    elif is_full() or occupier:
        disabled = true
        return
    else:
        texture = state_textures[1]

    # Sync cell states — occupied cells stay disabled regardless of board state
    for r in cells:
        for c in r:
            c.disabled = disabled or not c.occupier.is_empty()
