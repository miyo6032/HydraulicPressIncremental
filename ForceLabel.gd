extends Label

func _ready():
    EventBus.current_force_changed.connect(current_force_changed)
    
func current_force_changed(force, max_force):
    text = "%.2f tons" % force
    if force / max_force < 0.5:
        add_theme_color_override("font_color", Color.WHITE)
    elif force / max_force > 0.95:
        add_theme_color_override("font_color", Color.RED)
    else:
        add_theme_color_override("font_color", Color.YELLOW)        
