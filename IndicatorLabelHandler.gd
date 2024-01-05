extends Control

@onready var label_scene = load("res://indicator_label.tscn")

func _ready():
    EventBus.crushable_removed.connect(crushable_removed)

func crushable_removed(crushable):
    var label = label_scene.instantiate()    
    var label_text = ""    
    if crushable.is_crushed:
        label_text += "Press!"
    else:
        label.add_theme_color_override("font_color", Color.RED)
    label_text += " $%s" % Utils.format_num(crushable.get_value())
    label.text = label_text
    add_child(label)    
