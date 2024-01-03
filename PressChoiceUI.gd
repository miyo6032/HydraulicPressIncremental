extends MarginContainer

var press

func _ready():
    $MarginContainer/VBoxContainer/Button.pressed.connect(func(): EventBus.press_selected.emit(press))
    
func init(press_res: PressRes):
    $MarginContainer/VBoxContainer/PressTexture.texture = press_res.texture
    $MarginContainer/VBoxContainer/Label.text = press_res.name + "\n" + press_res.description
    press = press_res
