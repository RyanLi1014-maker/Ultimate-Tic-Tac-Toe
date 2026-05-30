# Manages sound effect playback with a reusable player pool.
# Callers can await play_sfx() to wait for a sound to finish (e.g. before quitting),
# Or fire-and-forget by calling it without await.
extends Node

const BUTTON_PRESS = preload("res://asset/sound/button_press.mp3")

const POOL_SIZE := 8
var _players_pool: Array[AudioStreamPlayer] = []


func _ready() -> void:
    process_mode = Node.PROCESS_MODE_ALWAYS
    # Pre-allocate a pool of audio players to avoid allocation overhead
    for i in POOL_SIZE:
        var player = AudioStreamPlayer.new()
        add_child(player)
        _players_pool.append(player)


# Returns an idle player from the pool, or null if all are busy.
func _get_free_player() -> AudioStreamPlayer:
    for player in _players_pool:
        if not player.playing:
            return player
    return null


# Plays a sound effect that ignore scene switching and pausing.
# Applicable to system sounds such as button presses, not game sounds.
func play_sfx(stream: AudioStream) -> void:
    var player = _get_free_player()
    if not player: # If all pool players are busy, creates a temporary one
        player = AudioStreamPlayer.new()
        add_child(player)
        player.finished.connect(player.queue_free) # Destroy when finished
    player.stream = stream
    player.play()
    await player.finished
