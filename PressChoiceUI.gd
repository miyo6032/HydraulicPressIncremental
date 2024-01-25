extends MarginContainer

var press
@export var unknown_texture: Texture2D
@onready var texture_rect = $MarginContainer/VBoxContainer/PressTexture
@onready var label = $MarginContainer/VBoxContainer/Label
@onready var button = $MarginContainer/VBoxContainer/Button

func _ready():
    $MarginContainer/VBoxContainer/Button.pressed.connect(func(): EventBus.new_press_selected.emit(press))

func init(press_res: PressRes):
    press = press_res

func set_unknown():
    button.disabled = true
    button.text = "???"
    texture_rect.texture = unknown_texture
    label.text = "\nunknown..."

func set_available():
    button.disabled = false
    button.text = "Choose"
    texture_rect.texture = press.texture
    label.text = press.name + "\n" + press.description
