extends Control

@onready var label_scene = load("res://indicator_label.tscn")

func _ready():
    EventBus.crushable_crushed.connect(crushable_crushed)

func crushable_crushed(crushable):
    var label = label_scene.instantiate()    
    var label_text = ""    
    if crushable.is_crushed:
        if crushable.is_quality:
            label_text = "Quality!"
        else:
            label_text += "Press!"
    else:
        label.add_theme_color_override("font_color", Color.RED)
    label_text += " $%s" % Utils.format_currency(crushable.get_value())
    label.text = label_text
    label.position = -label.size * 0.5
    add_child(label)    
