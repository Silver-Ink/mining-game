class_name ToolBar extends CanvasLayer

@onready var pickaxe: Button = %Pickaxe
@onready var hammer: Button = %Hammer
@onready var collapse_progress: ProgressBar = %CollapseProgress

func _ready() -> void:
	pickaxe.button_down.connect(_on_click.bind(ToolManager.tool.pickaxe))
	hammer.button_down.connect(_on_click.bind(ToolManager.tool.hammer))
	
func init(excavate_area : ExcavateArea) -> void:
	collapse_progress.max_value = excavate_area.max_collapse_life
	collapse_progress.min_value = 0
	excavate_area.collapse_life_changed.connect(on_collapse_life_changed)
	
func _on_click(t: ToolManager.tool):
	ToolManager.change_tool(t)

func on_collapse_life_changed(life : int) -> void:
	collapse_progress.value = life
