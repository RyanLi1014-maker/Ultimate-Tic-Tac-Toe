# Resume menu — lists saved games and lets the player continue or delete them.
extends Control

const MAIN_MENU_PATH := "res://scene/main_menu.tscn"
const GAME_SCENE_PATH := "res://scene/ultimate_tic_tac_toe_game.tscn"

var selected_item_index: int
var selected_item_text: String


func _ready() -> void:
    # Populate the list with saved game timestamps
    for k in Config.chess_games.keys():
        $VBoxContainer/ItemList.add_item(k)


# Stores the selected save game index and text when a list item is clicked.
func _on_item_list_item_clicked(
    index: int,
    _at_position: Vector2,
    _mouse_button_index: int
) -> void:
    SoundManager.play_sfx(SoundManager.BUTTON_PRESS)
    selected_item_index = index
    selected_item_text = $VBoxContainer/ItemList.get_item_text(index)


func _on_return_button_pressed() -> void:
    SoundManager.play_sfx(SoundManager.BUTTON_PRESS)
    get_tree().change_scene_to_file(MAIN_MENU_PATH)


func _on_delete_button_pressed() -> void:
    SoundManager.play_sfx(SoundManager.BUTTON_PRESS)
    if selected_item_text:
        Config.chess_games.erase(selected_item_text)
        Config.save_chess_games()
        $VBoxContainer/ItemList.remove_item(selected_item_index)


func _on_continue_button_pressed() -> void:
    SoundManager.play_sfx(SoundManager.BUTTON_PRESS)
    if selected_item_text:
        var resume_data = Config.chess_games[selected_item_text]
        Config.chess_games.erase(selected_item_text) # Remove the save so it can't be resumed twice
        Config.save_chess_games()
        Global.temp_values["resume_data"] = resume_data
        get_tree().change_scene_to_file(GAME_SCENE_PATH)
