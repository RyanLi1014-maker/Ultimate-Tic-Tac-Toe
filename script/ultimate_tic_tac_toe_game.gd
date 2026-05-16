extends Control

var current_player_info_textures = [
    preload("res://asset/image/texture/chess_piece/X.png"),
    preload("res://asset/image/texture/chess_piece/O.png")
]

func _ready():
    $BigChessboard.win.connect(_on_big_chessboard_win)

func _process(_delta):
    $CurrentPlayerInfo/TextureRect.texture.atlas = current_player_info_textures[Global.current_player - 1]

func _input(event):
    if event.is_action("ui_cancel"):
        get_tree().quit()

func _on_big_chessboard_win(winner: int):
    print(winner)
    $WinnerMessage/Label.text = "Player " + str(winner) + " wins!"
    $WinnerMessage.visible = true
