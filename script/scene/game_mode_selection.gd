extends Control

const GAME_SCENE_PATH := "res://scene/ultimate_tic_tac_toe_game.tscn"
const MAIN_MENU_PATH := "res://scene/main_menu.tscn"


func _on_strategy_button_pressed() -> void:
    SoundManager.play_sfx(SoundManager.BUTTON_PRESS)
    Global.temp_values["game_mode"] = "Strategy"
    get_tree().change_scene_to_file(GAME_SCENE_PATH)


func _on_normal_button_pressed() -> void:
    SoundManager.play_sfx(SoundManager.BUTTON_PRESS)
    Global.temp_values["game_mode"] = "Normal"
    get_tree().change_scene_to_file(GAME_SCENE_PATH)


func _on_quick_button_pressed() -> void:
    SoundManager.play_sfx(SoundManager.BUTTON_PRESS)
    Global.temp_values["game_mode"] = "Quick"
    get_tree().change_scene_to_file(GAME_SCENE_PATH)


func _on_return_button_pressed() -> void:
    SoundManager.play_sfx(SoundManager.BUTTON_PRESS)
    get_tree().change_scene_to_file(MAIN_MENU_PATH)
