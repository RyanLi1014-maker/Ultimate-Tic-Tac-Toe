# Main game scene controller for Ultimate Tic-Tac-Toe.
# Coordinates the big chessboard, pause menu, winner display, and save/resume logic.
extends Control

const MAIN_MENU_PATH := "res://scene/main_menu.tscn"
const GAME_SCENE_PATH := "res://scene/ultimate_tic_tac_toe_game.tscn"
const BOARD_DATA_SIZE := 3
const CELLS_SIZE := 3

var current_player = "X"
var current_player_info_textures = {
    "X": preload("res://asset/image/texture/chess_piece/X.png"),
    "O": preload("res://asset/image/texture/chess_piece/O.png")
}

var pause_sound: AudioStream = preload("res://asset/sound/pause.mp3")
var unpause_sound: AudioStream = preload("res://asset/sound/unpause.mp3")

var game_name: String = ""
var game_mode: String = "Normal"

@onready var big_chessboard: BigChessboard = $BigChessboard


func _ready() -> void:
    # Restore the game name and game mode
    var temp_game_name = Global.temp_values.get("game_name")
    Global.temp_values.erase("game_name")
    game_name = temp_game_name if temp_game_name else game_name
    var temp_game_mode = Global.temp_values.get("game_mode")
    Global.temp_values.erase("game_mode")
    game_mode = temp_game_mode if temp_game_mode else game_mode
    # Restore a saved game if we came from the resume menu
    if game_name:
        var resume_data = Config.chess_games[game_name]
        Config.chess_games.erase(game_name) # Remove the save so it can't be resumed twice
        Config.save_chess_games()
        _restore_board(resume_data)
        game_mode = resume_data["game_mode"]
    _update_player_display()
    $GameInfo/VBoxContainer/GameNameLabel.text = game_name \
        if game_name \
        else "[%s] New Game" % game_mode


func _input(event) -> void:
    if event.is_action_pressed("ui_cancel"):
        SoundManager.play_sfx(pause_sound)
        get_tree().paused = true
        $PauseMenu.visible = true


# Board save/resume logic=================================================


# Restores the full board state from saved resume data.
# Re-detects small-board winners directly instead of emitting dummy signals
# to avoid unnecessary cascade through the big-board target logic.
func _restore_board(resume_data: Dictionary) -> void:
    current_player = resume_data["current_player"]
    for r in BOARD_DATA_SIZE:
        for c in BOARD_DATA_SIZE:
            var board: SmallChessboard = big_chessboard.small_chessboards[r][c]
            board.disabled = resume_data["data"][r][c]["disabled"]
            _restore_board_cells(board, resume_data["data"][r][c]["cells"])
            # Re-detect small-board wins/ties and update visuals directly
            _restore_board_state(board)


# Re-detects a small board's winner/tie state and updates its visuals.
# Same logic as SmallChessboard._on_cell_occupied without emitting signals.
func _restore_board_state(board: SmallChessboard) -> void:
    var winner := board.check_winner()
    if winner:
        board.occupier = winner
        board.disabled = true
        match winner:
            "X":
                board.get_node("Icon_X").visible = true
                board.get_node("Icon_X").play("appear")
            "O":
                board.get_node("Icon_O").visible = true
                board.get_node("Icon_O").play("appear")
    elif board.is_full():
        board.disabled = true


# Restores all cell occupiers and their visual pieces for one small board.
func _restore_board_cells(board: SmallChessboard, cells_data: Array) -> void:
    for sub_r in CELLS_SIZE:
        for sub_c in CELLS_SIZE:
            var cell: Cell = board.cells[sub_r][sub_c]
            cell.occupier = cells_data[sub_r][sub_c]
            if cell.occupier:
                cell.disabled = true
                _show_cell_piece(cell, cell.occupier)


# Serializes the entire board state (all 9 small boards × 9 cells) into a Dictionary.
func _save_board_state() -> Dictionary:
    var data = {"data": [], "current_player": current_player}
    for r in BOARD_DATA_SIZE:
        data["data"].append([])
        for c in BOARD_DATA_SIZE:
            var board: SmallChessboard = big_chessboard.small_chessboards[r][c]
            data["data"][r].append({
                "cells": _save_board_cells(board),
                "disabled": board.disabled
            })
    return data


# Serializes the 3×3 cell occupiers of one small board into a 2D Array.
func _save_board_cells(board: SmallChessboard) -> Array:
    var cells_data := []
    for sub_r in CELLS_SIZE:
        var row := []
        for sub_c in CELLS_SIZE:
            row.append(board.cells[sub_r][sub_c].occupier)
        cells_data.append(row)
    return cells_data


# Player update logic=====================================================


# Toggles the active player and updates the display.
func update_current_player() -> void:
    current_player = "X" if current_player == "O" else "O"
    _update_player_display()


# Refreshes the current-player indicator in the HUD.
func _update_player_display() -> void:
    $CurrentPlayerInfo/VBoxContainer/TextureRect.texture.atlas = \
        current_player_info_textures[current_player]


# Shows the chess piece node for a cell with appear animation.
# Uses get_node for direct child lookup (faster than recursive find_child).
static func _show_cell_piece(cell: Cell, occupier: String) -> void:
    var piece := cell.get_node("ChessPiece_X") if occupier == "X" else cell.get_node("ChessPiece_O")
    piece.visible = true
    piece.play("appear")


# Signal handlers=========================================================


func _on_big_chessboard_win(winner: String) -> void:
    if winner: # If there's a winner, show the winner message
        $WinnerMessage/VBoxContainer/Label.text = "Player " + winner + " wins!"
    else: # If there's no winner, show the draw message
        $WinnerMessage/VBoxContainer/Label.text = "It's a draw!"
    $WinnerMessage.visible = true


func _on_restart_button_pressed() -> void:
    SoundManager.play_sfx(SoundManager.BUTTON_PRESS)
    Global.temp_values["game_mode"] = game_mode
    get_tree().paused = false
    get_tree().change_scene_to_file(GAME_SCENE_PATH)


func _on_exit_button_pressed() -> void:
    SoundManager.play_sfx(SoundManager.BUTTON_PRESS)
    get_tree().paused = false
    get_tree().change_scene_to_file(MAIN_MENU_PATH)


func _on_save_exit_button_pressed() -> void:
    SoundManager.play_sfx(SoundManager.BUTTON_PRESS)
    if game_name:
        var save_name = Global.get_unique_filename(game_name, Config.chess_games.keys())
        Config.chess_games[save_name] = _save_board_state()
        Config.chess_games[save_name]["game_mode"] = game_mode
        get_tree().paused = false
        get_tree().change_scene_to_file(MAIN_MENU_PATH)
    else:
        var entry := $GameNameEdit/VBoxContainer/LineEdit
        entry.text = Global.strip_game_mode_prefix(game_name) if game_name \
            else Time.get_datetime_string_from_system(false, true)
        entry.select_all()
        entry.grab_focus()
        $GameNameEdit.visible = true


func _on_continue_button_pressed() -> void:
    SoundManager.play_sfx(unpause_sound)
    get_tree().paused = false
    $PauseMenu.visible = false


func _on_game_name_edit_confirm_button_pressed() -> void:
    SoundManager.play_sfx(SoundManager.BUTTON_PRESS)
    var entry_text: String = $GameNameEdit/VBoxContainer/LineEdit.text
    var save_name: String
    if entry_text:
        # Preserve an existing game-mode prefix, or prepend one
        save_name = entry_text if entry_text.begins_with("[") \
            else "[%s] %s" % [game_mode, entry_text]
    else:
        save_name = "[%s] %s" % [game_mode, Time.get_datetime_string_from_system(false, true)]
    # Make sure the game name is unique
    save_name = Global.get_unique_filename(save_name, Config.chess_games.keys())
    Config.chess_games[save_name] = _save_board_state()
    Config.chess_games[save_name]["game_mode"] = game_mode
    Config.save_chess_games()
    $GameNameEdit.visible = false
    get_tree().paused = false
    get_tree().change_scene_to_file(MAIN_MENU_PATH)
