# Main menu screen with Start, Resume, and Quit buttons.
extends Control

const GAME_SCENE_PATH := "res://scene/ultimate_tic_tac_toe_game.tscn"
const RESUME_MENU_PATH := "res://scene/resume_menu.tscn"


func _input(event) -> void:
    if event.is_action_pressed("ui_cancel"):
        get_tree().quit()


func _on_start_button_pressed() -> void:
    SoundManager.play_sfx(SoundManager.BUTTON_PRESS)
    get_tree().change_scene_to_file(GAME_SCENE_PATH)


func _on_resume_button_pressed() -> void:
    SoundManager.play_sfx(SoundManager.BUTTON_PRESS)
    get_tree().change_scene_to_file(RESUME_MENU_PATH)


func _on_quit_button_pressed() -> void:
    # Wait for the click sound to play before quitting
    await SoundManager.play_sfx(SoundManager.BUTTON_PRESS)
    get_tree().quit()
