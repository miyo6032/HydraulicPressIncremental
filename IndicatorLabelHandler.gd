extends Control

@onready var label_scene = load("res://indicator_label.tscn")

func _ready():
    EventBus.crushable_removed.connect(crushable_removed)
    Console.add_command("l", spawn_label)
    
func spawn_label(text):
    var label = label_scene.instantiate()
    label.text = text
    add_child(label)
    
func crushable_removed(crushable):
    var label = ""    
    if crushable.is_crushed:
        label += "Crush!"
    label += " $%s" % Utils.format_num(crushable.get_value())
    spawn_label(label)
