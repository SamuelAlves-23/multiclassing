extends Node

@onready var audio_player: AudioStreamPlayer = $AudioStreamPlayer
@onready var lobby_music: String = "res://audio/lobby_music.mp3"
@onready var battle_music: String = "res://audio/battle_music.mp3"



func _ready() -> void:
	change_music_lobby()

func change_music_lobby():
	audio_player.stop()
	audio_player.stream = load(lobby_music)
	audio_player.play()

func change_music_battle():
	audio_player.stop()
	audio_player.stream = load(battle_music)
	audio_player.play()
