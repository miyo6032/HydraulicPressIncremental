extends Window

@onready var shape_list: ShapeList = load("res://data/shape_list.tres")
@onready var pattern_list: PatternList = load("res://data/pattern_list.tres")
@onready var crushable_scene: PackedScene = load("res://crushable.tscn")
@onready var list: GridContainer = $GridContainer
@onready var value_item_scene: PackedScene = load("res://value_item.tscn")

func _ready():
    hide()
    for shape in shape_list.shapes:
        for pattern in pattern_list.patterns:
            var crushable = crushable_scene.instantiate()
            crushable.init_no_visuals(shape, pattern)
            crushable.set_crushed_no_events(CrushModifiers.new())
            var value_item = value_item_scene.instantiate()
            list.add_child(value_item)            
            value_item.init("$%s" % Utils.format_currency(crushable.get_value()), crushable.crushable_shape, crushable.crushable_pattern)

func _on_close_requested():
    hide()
