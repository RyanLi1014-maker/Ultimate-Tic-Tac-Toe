extends TextureButton
class_name Cell

var occupier: int = 0 # 0 = empty, 1 = X, 2 = O

signal cell_occupied(position: Vector2)

func _process(_delta):
    if occupier != 0:
        disabled = true

func _on_pressed():
    disabled = true
    occupier = Global.current_player
    Global.update_current_player()
    match occupier:
        1:
            $ChessPiece_X.visible = true
            $ChessPiece_X.play("appear")
        2:
            $ChessPiece_O.visible = true
            $ChessPiece_O.play("appear")
    cell_occupied.emit(Vector2(position.x / 24, get_parent().position.y / 24))
