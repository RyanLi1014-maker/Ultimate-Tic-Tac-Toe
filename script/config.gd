# Persistent save/load manager for chess game data.
# Stores game snapshots keyed by timestamp so players can resume later.
extends Node

var chess_games: Dictionary # All saved games, keyed by timestamp string


func _ready() -> void:
    load_chess_games()


# Loads saved games from disk into chess_games.
# Returns the loaded dictionary, or an empty dict if no save exists.
func load_chess_games() -> Dictionary:
    if FileAccess.file_exists("user://chess_games.dat"):
        var file = FileAccess.open("user://chess_games.dat", FileAccess.READ)
        var data = file.get_var()
        if data != null and typeof(data) == TYPE_DICTIONARY:
            chess_games = data
            return chess_games
    chess_games = {}
    save_chess_games()
    return {}


# Writes chess_games to disk.
func save_chess_games() -> void:
    var file = FileAccess.open("user://chess_games.dat", FileAccess.WRITE)
    file.store_var(chess_games)
