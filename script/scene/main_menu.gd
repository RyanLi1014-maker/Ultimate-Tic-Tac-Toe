# Main menu screen with Start, Resume, and Quit buttons.
extends Control

const GAME_MODE_SELECTION_PATH := "res://scene/game_mode_selection.tscn"
const RESUME_MENU_PATH := "res://scene/resume_menu.tscn"


func _ready() -> void:
    var version_number = ProjectSettings.get_setting("application/config/version")
    $VersionLabel.text = "Version v" + version_number + "\n" \
        + "By RyanLi1014-marker <ryanli1014@outlook.com>"


func _on_start_button_pressed() -> void:
    SoundManager.play_sfx(SoundManager.BUTTON_PRESS)
    get_tree().change_scene_to_file(GAME_MODE_SELECTION_PATH)


func _on_resume_button_pressed() -> void:
    SoundManager.play_sfx(SoundManager.BUTTON_PRESS)
    get_tree().change_scene_to_file(RESUME_MENU_PATH)


func _on_quit_button_pressed() -> void:
    # Wait for the click sound to finish before quitting
    await SoundManager.play_sfx(SoundManager.BUTTON_PRESS)
    get_tree().quit()
