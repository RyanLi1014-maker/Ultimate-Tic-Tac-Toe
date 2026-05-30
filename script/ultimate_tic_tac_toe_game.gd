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

@onready var big_chessboard: BigChessboard = $BigChessboard


func _ready() -> void:
    # Restore a saved game if we came from the resume menu
    var resume_data = Global.temp_values.get("resume_data")
    if resume_data:
        _restore_board(resume_data)
        Global.temp_values["resume_data"] = null
    _update_player_display()


func _input(event) -> void:
    if event.is_action_pressed("ui_cancel"):
        SoundManager.play_sfx(pause_sound)
        get_tree().paused = true
        $PauseMenu.visible = true


func _on_big_chessboard_win(winner: String) -> void:
    $WinnerMessage/VBoxContainer/Label.text = "Player " + winner + " wins!"
    $WinnerMessage.visible = true


func _on_restart_button_pressed() -> void:
    SoundManager.play_sfx(SoundManager.BUTTON_PRESS)
    get_tree().paused = false
    get_tree().change_scene_to_file(GAME_SCENE_PATH)


func _on_back_button_pressed() -> void:
    SoundManager.play_sfx(SoundManager.BUTTON_PRESS)
    # Save the current game state only if no winner yet
    if not big_chessboard.check_winner():
        Config.chess_games[Time.get_datetime_string_from_system()] = _save_board_state()
        Config.save_chess_games()
    get_tree().paused = false
    get_tree().change_scene_to_file(MAIN_MENU_PATH)


func _on_continue_button_pressed() -> void:
    SoundManager.play_sfx(unpause_sound)
    get_tree().paused = false
    $PauseMenu.visible = false


# Restores the full board state from saved resume data.
func _restore_board(resume_data: Dictionary) -> void:
    current_player = resume_data["current_player"]
    for r in BOARD_DATA_SIZE:
        for c in BOARD_DATA_SIZE:
            var board: SmallChessboard = big_chessboard.small_chessboards[r][c]
            board.disabled = resume_data["data"][r][c]["disabled"]
            _restore_board_cells(board, resume_data["data"][r][c]["cells"])
            # Re-detect any board-level wins so the big board and icons update
            board._on_cell_occupied(Vector2.ZERO)


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


# Toggles the active player and updates the display.
func update_current_player() -> void:
    current_player = "X" if current_player == "O" else "O"
    _update_player_display()


# Refreshes the current-player indicator in the HUD.
func _update_player_display() -> void:
    $CurrentPlayerInfo/TextureRect.texture.atlas = current_player_info_textures[current_player]


# Shows the chess piece node for a cell with appear animation.
static func _show_cell_piece(cell: Cell, occupier: String) -> void:
    var piece := cell.find_child("ChessPiece_X") if occupier == "X" else cell.find_child("ChessPiece_O")
    piece.visible = true
    piece.play("appear")
