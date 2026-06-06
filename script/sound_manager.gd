# Manages sound effect playback with a reusable player pool.
# Callers can await play_sfx() to wait for a sound to finish (e.g. before quitting),
# or fire-and-forget by calling it without await.
extends Node

const BUTTON_PRESS := preload("res://asset/sound/button_press.mp3")

const POOL_SIZE := 8
var _players_pool: Array[AudioStreamPlayer] = []
var _next_idx := 0 # Round-robin index to distribute pool usage evenly


func _ready() -> void:
    process_mode = Node.PROCESS_MODE_ALWAYS
    # Pre-allocate a pool of audio players to avoid per-call allocation overhead
    for _i in POOL_SIZE:
        var player := AudioStreamPlayer.new()
        add_child(player)
        _players_pool.append(player)


# Returns an idle player from the pool using round-robin search, or null if all busy.
func _get_free_player() -> AudioStreamPlayer:
    for offset in POOL_SIZE:
        var idx := (_next_idx + offset) % POOL_SIZE
        var player := _players_pool[idx]
        if not player.playing:
            _next_idx = (idx + 1) % POOL_SIZE
            return player
    return null


# Plays a sound effect that ignores scene switching and pausing.
# Suitable for system sounds such as button presses, not in-game sounds.
# Await the returned signal to block until the sound finishes; omit await for fire-and-forget.
func play_sfx(stream: AudioStream) -> void:
    var player := _get_free_player()
    if not player: # All pool players busy — create a temporary one that self-destructs
        player = AudioStreamPlayer.new()
        add_child(player)
        player.finished.connect(player.queue_free)
    player.stream = stream
    player.play()
    await player.finished
