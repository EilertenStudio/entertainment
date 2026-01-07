class_name MusicPlayer extends Control

@export var track_dir_path_env := "APP_MUSIC_MANAGER_TRACKS_DIR"
@export var track_dir_path := "data/music/tracks"
@export var track_extension_allowed : Array[String] = [
	"mp3"
]
@export var playlist: Array[String] = []
@export var playlist_autorun := false
@export var playlist_track_index: int

@onready var player: AudioStreamPlayer = $AudioStreamPlayer
@export_range(-80, 24, 0.1) var player_volume_db: float = 0.0:
	set(value):
		player_volume_db = value
		if player:
			player.volume_db = value

func _ready() -> void:
	if process_mode == ProcessMode.PROCESS_MODE_DISABLED: return
	
	# == Initialize variables
	if OS.has_environment(track_dir_path_env):
		track_dir_path = OS.get_environment(track_dir_path_env)
	else:
		var base_path: String
		
		if OS.has_feature("editor"):
			base_path = ProjectSettings.globalize_path("res://")
		else:
			base_path = OS.get_executable_path().get_base_dir()
			
		track_dir_path = base_path.path_join(track_dir_path)
	
	# == Initialize playlist
	playlist_load()
	
	if playlist.size() > 0:
		if playlist_autorun: playlist_track_play(0)
	else:
		print("No track available in the playlist to play")
	
	# == Initialize player
	player.volume_db = player_volume_db
	player.connect('finished', playlist_track_next)

func playlist_load():
	var dir = DirAccess.open(track_dir_path)
	
	print("Get access to directory %s - %s" % [track_dir_path, dir])
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		
		while file_name != "":
			if !dir.current_is_dir() and track_extension_allowed.has(file_name.get_extension()):
				print("Detect track to load in playlist: '%s'" % [ file_name ])
				playlist.append(file_name)
				pass
				
			file_name = dir.get_next()
	
		print("Track loaded in playlist: %s" % playlist.size())

func playlist_track_load(track_name: String):
	var file_path = track_dir_path.path_join(track_name)
	var file = FileAccess.open(file_path, FileAccess.READ)
	
	print("Get access to file %s - %s" % [file_path, file])
	if file:
		var stream = AudioStreamMP3.new()
		stream.data = file.get_buffer(file.get_length())
		return stream
	else:
		return null

func playlist_track_play(track_index: int):
	if track_index >= playlist.size(): return
	
	var track_name = playlist[track_index]
	var track_stream = playlist_track_load(track_name)
	
	if track_stream:
		playlist_track_index = track_index
		player.set_stream(track_stream)
		player.play()
		print("Playlist track '%s' in playing" % [track_name])

func playlist_track_next():
	var track_index = (playlist_track_index + 1) % playlist.size()
	playlist_track_play(track_index)
