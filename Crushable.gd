extends Node2D

@onready var sprite: Sprite2D = $Sprite2D

func update_crush(size):
    scale.y = clamp(size / sprite.texture.get_height(), 0.1, 1)
