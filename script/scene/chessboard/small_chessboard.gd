# A single 3×3 small board within the larger Ultimate Tic-Tac-Toe grid.
# Manages its 9 child cells, detects wins/ties, and updates its visual
# state (enabled/disabled texture + winner icon) whenever the disabled property changes.
extends TextureRect
class_name SmallChessboard

const BOARD_SPACING := 88 # Pixel distance between boards in the big-board layout

const STATE_TEXTURES := [
    preload("res://asset/image/texture/chessboard/small_chessboard_disable.png"),
    preload("res://asset/image/texture/chessboard/small_chessboard_enable.png"),
]

var disabled := false:
    set(value):
        if disabled == value:
            return
        disabled = value
        _refresh()

var occupier: String = "" # "X" or "O" once won; "" if undecided

@onready var game = get_tree().current_scene
@onready var _icon_x := $Icon_X
@onready var _icon_o := $Icon_O
@onready var _parent := get_parent()

var cells := [[], [], []] # 3×3 grid of Cell references

signal small_chessboard_occupied(grid_position: Vector2) # This board's position in the big board


func _ready() -> void:
    # Build the 2D cell grid from the scene hierarchy and connect signals
    var rows := $VBoxContainer.get_children()
    for r_idx in rows.size():
        var row := rows[r_idx]
        var col_nodes := row.get_children()
        for c_idx in col_nodes.size():
            var cell := col_nodes[c_idx]
            cells[r_idx].append(cell)
            cell.cell_occupied.connect(_on_cell_occupied)
    _refresh()


# Called when a cell inside this board is pressed.
# Checks for a winner — if found, marks the board as won and plays the
# winner icon animation. If the board is full with no winner, marks it tied.
func _on_cell_occupied(_cell_grid_position: Vector2) -> void:
    var winner := check_winner()
    if winner:
        occupier = winner
        disabled = true
        match winner:
            "X":
                _icon_x.visible = true
                _icon_x.play("appear")
            "O":
                _icon_o.visible = true
                _icon_o.play("appear")
        small_chessboard_occupied.emit(Vector2(
            position.x / BOARD_SPACING, _parent.position.y / BOARD_SPACING
        ))
    elif is_full():
        disabled = true


# Returns true if all 9 cells are occupied (draw).
func is_full() -> bool:
    for r in cells:
        for c in r:
            if c.occupier.is_empty():
                return false
    return true


# Checks this board's 3×3 for a win (rows, columns, diagonals).
# Accesses cells directly to avoid allocating an intermediate occupiers array.
# Returns "X", "O", or "" (no winner).
func check_winner() -> String:
    if occupier:
        return ""

    # Rows
    for i in 3:
        if _three_equal(cells[i][0].occupier, cells[i][1].occupier, cells[i][2].occupier):
            return cells[i][0].occupier

    # Columns
    for j in 3:
        if _three_equal(cells[0][j].occupier, cells[1][j].occupier, cells[2][j].occupier):
            return cells[0][j].occupier

    # Diagonals
    if _three_equal(cells[0][0].occupier, cells[1][1].occupier, cells[2][2].occupier):
        return cells[0][0].occupier
    if _three_equal(cells[0][2].occupier, cells[1][1].occupier, cells[2][0].occupier):
        return cells[0][2].occupier

    return ""


# Returns true if all three strings are non-empty and equal.
static func _three_equal(a: String, b: String, c: String) -> bool:
    return not a.is_empty() and a == b and b == c


# Applies the current disabled state to the board's texture and all child cells.
# If re-enabling but the board is full or won, it re-disables itself.
func _refresh() -> void:
    if disabled:
        texture = STATE_TEXTURES[0]
    elif is_full() or (occupier and game.game_mode != "Strategy"):
        disabled = true
        return
    else:
        texture = STATE_TEXTURES[1]

    # Sync cell states — occupied cells stay disabled regardless of board state
    for r in cells:
        for c in r:
            c.disabled = disabled or not c.occupier.is_empty()
