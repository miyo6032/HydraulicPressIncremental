extends Node2D

@onready var sprite: Sprite2D = $Sprite2D

var is_crushed = false

func update_crush(size):
    scale.y = clamp(size / sprite.texture.get_height(), 0.1, 1)

func get_value():
    return 1 if is_crushed else 0
