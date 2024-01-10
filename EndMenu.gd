extends Control

@onready var fade_ui = $EndMenuFadeUI

func show_end():
    fade_ui.fade_in()
    get_tree().paused = true
