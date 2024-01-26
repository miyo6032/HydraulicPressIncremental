extends Window

@onready var shape_list: ShapeList = load("res://data/shape_list.tres")
@onready var pattern_list: PatternList = load("res://data/pattern_list.tres")
@onready var crushable_scene: PackedScene = load("res://crushable.tscn")
@onready var list: GridContainer = $GridContainer
@onready var value_item_scene: PackedScene = load("res://value_item.tscn")
@onready var crushed_shapes = {}

func _ready():
    EventBus.upgrade_level_changed.connect(upgrade_level_changed)
    hide()
    for shape in shape_list.shapes:
        crushed_shapes[shape] = {}
        for pattern in pattern_list.patterns:
            crushed_shapes[shape][pattern] = false

var unlocked_shape_level: int
var unlocked_pattern_level: int

func upgrade_level_changed(instance):
    if instance.upgrade.upgrade_type == Enums.UpgradeType.Materials:
        unlocked_shape_level = instance.max_upgrade_level + 1
    if instance.upgrade.upgrade_type == Enums.UpgradeType.MaterialType:
        unlocked_pattern_level = instance.max_upgrade_level + 2

func open():
    show()
    for child in list.get_children():
        child.queue_free()
    for shape_level in unlocked_shape_level:
        for pattern_level in unlocked_pattern_level:
            var shape = shape_list.shapes[shape_level]
            var pattern = pattern_list.patterns[pattern_level]
            var crushable = crushable_scene.instantiate()
            crushable.init_no_visuals(shape, pattern)
            crushable.set_crushed_no_events(CrushModifiers.new())
            var value_item = value_item_scene.instantiate()
            list.add_child(value_item)
            value_item.init("$%s" % Utils.format_currency(crushable.get_value()), crushable.crushable_shape, crushable.crushable_pattern)

func _on_close_requested():
    hide()
