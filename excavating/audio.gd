extends Node
class_name Audio

var _stream: AudioStreamPlayer = AudioStreamPlayer.new()
var _lookup: Dictionary[String, AudioStream] = {}

func _ready():
	add_child(_stream)

func add_key(key: String, path: String):
	var stream = load(path) as AudioStream
	if stream:
		_lookup[key] = stream
	else:
		push_error("Failed to load audio stream from path: ", path)

func play(key: String):
	if _lookup.has(key):
		_stream.stream = _lookup[key]
		_stream.play()
	else:
		push_warning("No sound found for key: ", key)
