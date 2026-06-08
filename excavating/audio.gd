extends Node
class_name Audio

class AudioPlayer:
	var player: AudioStreamPlayer
	var stream: AudioStream
	
	func _init(path: String, parent: Node):
		stream = load(path) as AudioStream
		player = AudioStreamPlayer.new()
		player.stream = stream
		parent.add_child(player)

var _lookup: Dictionary[String, AudioPlayer] = {}

func add_key(key: String, path: String):
	var audio_player = AudioPlayer.new(path, self)
	_lookup[key] = audio_player

func play(key: String):
	if key == "":
		return
	if _lookup.has(key):
		_lookup[key].player.play()
	else:
		push_warning("No sound found for key: ", key)
