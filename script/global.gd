extends Node

# set current player to 2 first, if getcurrent_player is called, it will return 1
var current_player = 1

func update_current_player():
    current_player = 1 if current_player == 2 else 2
