# Resume menu — lists saved games and lets the player continue or delete them.
extends Control

const MAIN_MENU_PATH := "res://scene/main_menu.tscn"
const GAME_SCENE_PATH := "res://scene/ultimate_tic_tac_toe_game.tscn"

var selected_item_index: int = -1
var selected_item_text: String = ""


func _ready() -> void:
    # Populate the list with saved game timestamps
    for k in Config.chess_games:
        $GameList/ItemList.add_item(k)


# Resume the selected game when the list item is activated.
func _on_item_list_item_activated(_index: int) -> void:
    _on_continue_button_pressed()


# Stores the selected save game index and text when a list item is selected.
func _on_item_list_item_selected(index: int) -> void:
    SoundManager.play_sfx(SoundManager.BUTTON_PRESS)
    selected_item_index = index
    selected_item_text = $GameList/ItemList.get_item_text(index)


# Return to the main menu when the return button is pressed.
func _on_return_button_pressed() -> void:
    SoundManager.play_sfx(SoundManager.BUTTON_PRESS)
    get_tree().change_scene_to_file(MAIN_MENU_PATH)


# Delete the selected game when the delete button is pressed.
func _on_delete_button_pressed() -> void:
    SoundManager.play_sfx(SoundManager.BUTTON_PRESS)
    if selected_item_text:
        Config.chess_games.erase(selected_item_text)
        Config.save_chess_games()
        $GameList/ItemList.remove_item(selected_item_index)
        selected_item_index = -1
        selected_item_text = ""


# Show the name edit when the rename button is pressed.
func _on_rename_button_pressed() -> void:
    SoundManager.play_sfx(SoundManager.BUTTON_PRESS)
    if selected_item_text:
        var entry := $NameEdit/VBoxContainer/LineEdit
        entry.text = Global.strip_game_mode_prefix(selected_item_text)
        entry.select_all()
        entry.grab_focus()
        $NameEdit.visible = true


# Resume the selected game when the continue button is pressed.
func _on_continue_button_pressed() -> void:
    SoundManager.play_sfx(SoundManager.BUTTON_PRESS)
    if selected_item_text:
        Global.temp_values["game_name"] = selected_item_text
        get_tree().change_scene_to_file(GAME_SCENE_PATH)


func _on_name_edit_cancel_button_pressed() -> void:
    SoundManager.play_sfx(SoundManager.BUTTON_PRESS)
    $NameEdit/VBoxContainer/LineEdit.text = ""
    $NameEdit.visible = false


func _on_name_edit_confirm_button_pressed() -> void:
    SoundManager.play_sfx(SoundManager.BUTTON_PRESS)
    var entry := $NameEdit/VBoxContainer/LineEdit
    if entry.text:
        var game_mode: String = Config.chess_games[selected_item_text]["game_mode"]
        var game_name := "[%s] %s" % [game_mode, entry.text]
        if game_name != selected_item_text:
            game_name = Global.get_unique_filename(game_name, Config.chess_games.keys())
            Config.chess_games[game_name] = Config.chess_games[selected_item_text]
            Config.chess_games.erase(selected_item_text)
            Config.save_chess_games()
            var item_list := $GameList/ItemList
            item_list.remove_item(selected_item_index)
            item_list.add_item(game_name)
            item_list.move_item(item_list.get_item_count() - 1, selected_item_index)
            selected_item_text = game_name
            item_list.select(selected_item_index)
    entry.text = ""
    $NameEdit.visible = false
