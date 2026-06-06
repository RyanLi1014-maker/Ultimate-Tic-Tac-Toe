# Persistent save/load manager for chess game data.
# Stores game snapshots keyed by timestamp so players can resume later.
extends Node

const CHESS_GAMES_PATH := "user://chess_games.dat"

var chess_games: Dictionary # All saved games, keyed by timestamp string


func _ready() -> void:
    load_chess_games()


# Loads saved games from disk into chess_games.
# Returns the loaded dictionary, or an empty dict if no save exists.
func load_chess_games() -> Dictionary:
    var file := FileAccess.open(CHESS_GAMES_PATH, FileAccess.READ)
    if file:
        var data = file.get_var()
        if typeof(data) == TYPE_DICTIONARY:
            chess_games = data
            return chess_games
    chess_games = {}
    save_chess_games()
    return {}


# Writes chess_games to disk.
func save_chess_games() -> void:
    var file := FileAccess.open(CHESS_GAMES_PATH, FileAccess.WRITE)
    file.store_var(chess_games)
