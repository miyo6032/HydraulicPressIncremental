extends HBoxContainer

@onready var label = $Label
@onready var texture_rect = $TextureRect

func init(text, shape, pattern):
    label.text = text
    texture_rect.texture = shape.texture
    var material: ShaderMaterial = texture_rect.material
    material.set_shader_parameter("MainTex", pattern.texture)
