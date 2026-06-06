# A single playable cell inside a small chessboard.
# Handles click input, displays the player's piece with animation,
# and notifies parents of the cell's grid position for target-board logic.
extends TextureButton
class_name Cell

const CELL_SPACING := 24 # Pixel distance between cells in the scene layout

@onready var game = get_tree().current_scene
@onready var _piece_x := $ChessPiece_X
@onready var _piece_o := $ChessPiece_O
@onready var _place_sound := $PlaceChessPieceSound
@onready var _parent := get_parent()

var occupier: String = "" # "X" or "O" once played; "" if empty

signal cell_occupied(grid_position: Vector2) # (col, row) within the small board


func _on_pressed() -> void:
    _place_sound.play()
    disabled = true
    occupier = game.current_player
    game.update_current_player()

    # Show the correct chess piece with appear animation
    var piece := _piece_x if occupier == "X" else _piece_o
    piece.visible = true
    piece.play("appear")

    # Emit the cell's grid position so listeners can determine which
    # small board the next player must play in
    cell_occupied.emit(Vector2(
        position.x / CELL_SPACING,
        _parent.position.y / CELL_SPACING
    ))
