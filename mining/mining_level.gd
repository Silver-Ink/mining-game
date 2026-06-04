extends Scene
class_name MiningLevel

@onready var walls: WallTileMapLayer = $Walls

var character_ref : Character
var warp_zones : Dictionary[int, WarpZone] = {}

func _ready() -> void:
	_indexate_warp_zone()
	
func do_keep_alive() -> bool: #override
	return true

func on_popped() -> void: #override
	pass
	
class MiningLevelSceneSettings extends SceneSettings:
	var warp_zone_id : int
	func _init(warp_id : int) -> void:
		warp_zone_id = warp_id

func on_pushed(context : SceneContext, settings : SceneSettings) -> void: #override
	if (settings is MiningLevelSceneSettings):
		_set_as_current_level(context.character, settings.warp_zone_id)
	else: 
		push_error(SceneManager.push_scene.get_method(), " was called with an incorrect SceneSettings type, expected : MiningLevelSceneSettings \n",\
			Engine.capture_script_backtraces())


func _indexate_warp_zone() -> void:
	var container = $WarpZones
	for warp in container.get_children():
		if (warp is WarpZone):
			var id = warp.self_id
			if (id < 0):
				printerr("Invalid warp ID : ", id)
				return
			if (warp_zones.keys().has(id)):
				printerr("Two or more warp zones of a same level contains the same id : ", id)
				return
			warp_zones[id] = warp
			
		else:
			printerr("Warp Zones Container contains an unwanted node : ", warp.name)

func _set_as_current_level(character : Character, warp_id : int) -> void:
	character_ref = character
	if (character.get_parent() != null):
		character.reparent(self, false)
	else:
		add_child(character)
	_bind_references()
	
	if (warp_id >= 0):
		_set_character_to_warp(warp_id)
		
func _set_character_to_warp(warp_id : int) -> void:
	if (!warp_zones.keys().has(warp_id)):
		printerr("Trying to teleport to inexistant warp zone with id : ", warp_id)
		return
	warp_zones[warp_id].receive_character(character_ref)
	
func _bind_references() -> void:
	character_ref.walls = walls
