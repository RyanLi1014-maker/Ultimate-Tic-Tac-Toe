# A single playable cell inside a small chessboard.
# Handles click input, displays the player's piece with animation,
# And notifies parents of the cell's grid position for target-board logic.
extends TextureButton
class_name Cell

const CELL_SPACING := 24 # Pixel distance between cells in the scene layout

var occupier: String = "" # "X" or "O" once played; "" if empty

signal cell_occupied(grid_position: Vector2) # (col, row) within the small board


func _on_pressed() -> void:
    $PlaceChessPieceSound.play()
    disabled = true
    var game = get_tree().current_scene
    occupier = game.current_player
    game.update_current_player()

    # Show the correct chess piece with appear animation
    var piece := $ChessPiece_X if occupier == "X" else $ChessPiece_O
    piece.visible = true
    piece.play("appear")

    # Emit the cell's grid position so listeners can determine which
    # Small board the next player must play in
    cell_occupied.emit(
        Vector2(
            position.x / CELL_SPACING,
            get_parent().position.y / CELL_SPACING
        )
    )
