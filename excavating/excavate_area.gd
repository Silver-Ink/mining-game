class_name ExcavateArea extends Node2D

signal collapse_life_changed(life : int)
signal collapsed()

const NB_TILE_W = 13
const NB_TILE_H = 10
const TILE_EDGE = 8
const ROCK_TILE = preload("res://excavating/rock_tile.tscn")
const TOOLBAR = preload("res://ui/toolbar.tscn")

@onready var rock_tiles: Node2D = %rock_tiles
@onready var camera_2d: Camera2D = $Camera2D
@onready var discoveries: Node2D = %discoveries

var tiles : Array

@export var max_collapse_life := 1000
@export var to_spawn_discoveries : Array[PackedScene]
var collapse_life : int

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	collapse_life = max_collapse_life
	var toolbar : ToolBar = TOOLBAR.instantiate()
	toolbar.init.call_deferred(self)
	self.add_child(toolbar)
	
	ToolManager.tool_used.connect(_on_tool_used)
	collapsed.connect(_end_excavation)
	generate()
	ToolManager.init_excavation()

func _on_tool_used(t : ToolManager.tool) -> void:
	match t:
		ToolManager.tool.pickaxe:
			collapse_life -= 1
		ToolManager.tool.hammer:
			collapse_life -= 2
		ToolManager.tool.none:
			return
	collapse_life_changed.emit(collapse_life)
	if (collapse_life <= 0):
		collapsed.emit()
			

func get_tile_vec(pos: Vector2i, _checking_bounds:= false) -> rock_tile:
	return get_tile(pos.x, pos.y, _checking_bounds)

func get_tile(x: int, y:int, _checking_bounds := false) -> rock_tile:
	if (x<0 || x >= NB_TILE_W   \
	||  y<0 || y >= NB_TILE_H ):
		if (!_checking_bounds):
			printerr("accessing invalid tile coordinates : ", x, " ", y)
		return null
	return tiles[y * NB_TILE_W + x]

func generate() -> void:
	tiles.clear()
	tiles.resize(NB_TILE_H * NB_TILE_W)
	for line in range(NB_TILE_H):
		for col in range(NB_TILE_W):
			var tile : rock_tile = ROCK_TILE.instantiate()
			var pos = Vector2(col * TILE_EDGE, (line) * TILE_EDGE) + HALF_TILE_OFFSET
			tile.position = pos
			tile.id = line*NB_TILE_W + col
			tile.grid_pos = Vector2i(col, line)
			tile.excavate_area = self
			rock_tiles.add_child(tile)
			tiles[tile.id] = tile
	camera_2d.position = Vector2((NB_TILE_W / 2. ) * TILE_EDGE, (NB_TILE_H / 2. ) * TILE_EDGE + TILE_EDGE)
	
	place_discoveries()
	
# To get tiles corners rather than center
const HALF_TILE_OFFSET := Vector2(TILE_EDGE / 2., TILE_EDGE / 2.) 
# Avoid to spawn disco in an outer radius where no disco can fit anyway
const NO_SPAWN_TILE_RADIUS = 1 
						
const MIN_BOUNDS_POS := Vector2.ZERO
const MAX_BOUNDS_POS := Vector2((NB_TILE_W ) * TILE_EDGE, \
								(NB_TILE_H ) * TILE_EDGE)

const MIN_SPAWN_POS := Vector2(TILE_EDGE , TILE_EDGE) * NO_SPAWN_TILE_RADIUS - HALF_TILE_OFFSET
const MAX_SPAWN_POS := Vector2((NB_TILE_W - NO_SPAWN_TILE_RADIUS ) * TILE_EDGE, \
							   (NB_TILE_H - NO_SPAWN_TILE_RADIUS ) * TILE_EDGE) - HALF_TILE_OFFSET

var spawned_discoveries : Array[Discovery]

func _unhandled_input(event: InputEvent) -> void:
	if (event.is_action_pressed("ui_accept")):
		
		_randomize_discoveries(spawned_discoveries)
		print(_check_discoveries_fiting_in_bounds(spawned_discoveries), _check_not_overlapping_discoveries(spawned_discoveries))
			

func place_discoveries() -> void:
	for scene in to_spawn_discoveries:
		var disco : Discovery = scene.instantiate()
		spawned_discoveries.append(disco)
		discoveries.add_child(disco)
		
func _randomize_discoveries(_spawned_discoveries : Array[Discovery]) -> void: 
	for disco in _spawned_discoveries:
		disco.position = Vector2(randi_range(int(MIN_SPAWN_POS.x), int(MAX_SPAWN_POS.x)), \
								 randi_range(int(MIN_SPAWN_POS.y), int(MAX_SPAWN_POS.y)))
								
@onready var rect_visualiser: CollisionShape2D = $RectVisualiser
func _check_discoveries_fiting_in_bounds(_spawned_discoveries : Array[Discovery]) -> bool:
	var englobing_rect = RectangleShape2D.new()
	englobing_rect.size = MAX_BOUNDS_POS - MIN_BOUNDS_POS
	rect_visualiser.shape = englobing_rect
	#rect_visualiser.position = englobing_rect.size / 2.
	
	var enclosing = rect_visualiser.shape.get_rect()
	for disco in _spawned_discoveries:
		for rect in _get_rects(disco):
			if (!enclosing.encloses(rect)):
				return false
	return true
	#for disco in _spawned_discoveries:
		#for rect in _get_rects(disco):
			#if (rect.position < MIN_BOUNDS_POS || rect.end > MAX_BOUNDS_POS):
				#return false
		#
	#return true
	
func _check_not_overlapping_discoveries(spawned_discoveries : Array[Discovery]) -> bool:
	for disco_a in spawned_discoveries:
		for disco_b in spawned_discoveries:
			if (disco_a != disco_b):
				var rects_a = _get_rects(disco_a)
				var rects_b = _get_rects(disco_b)
				for rect_a in rects_a:
					for rect_b in rects_b:
						if (rect_a.intersects(rect_b)):
							return false
	return true
				
func _get_rects(discovery : Discovery) -> Array[Rect2]:
	var children = discovery.get_children()
	var rects : Array[Rect2]
	
	for node in children:
		if (node is CollisionShape2D):
			var rect = node.shape.get_rect()
			print(rect)
			rects.append(rect)
	return rects

func _end_excavation() -> void:
	ToolManager.end_excavation()
	print("Game over")
