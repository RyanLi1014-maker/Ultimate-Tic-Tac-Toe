# Global singleton for passing temporary data between scenes.
extends Node

var temp_values: Dictionary = {}


# Generates a unique filename by appending " (N)" if the base name already
# exists in existing_names. Uses linear scan — fine for the small list of
# saved games this operates on.
func get_unique_filename(base_name: String, existing_names: Array) -> String:
    if base_name not in existing_names:
        return base_name
    
    var counter = 1
    var new_name: String
    
    while true:
        new_name = base_name + " (" + str(counter) + ")"
        if new_name not in existing_names:
            return new_name
        counter += 1
    
    return new_name


# Strips the "[GameMode] " prefix from a saved game name, if present.
# Shared utility used by both the game scene and resume menu.
func strip_game_mode_prefix(base_name: String) -> String:
    var end_bracket := base_name.find("] ")
    if end_bracket != -1:
        return base_name.substr(end_bracket + 2)
    return base_name
