extends Label

func _ready():
    EventBus.current_force_changed.connect(current_force_changed)

func current_force_changed(force, max_force):
    text = "%.2f tons" % force
    var force_ratio = force / max_force

    if force_ratio < 0.5:
        add_theme_color_override("font_color", Color.WHITE)
    elif force_ratio > 5:
        add_theme_color_override("font_color", Color.PURPLE)
    elif force_ratio > 2:
        add_theme_color_override("font_color", Color.CORNFLOWER_BLUE)
    elif force_ratio > 0.95:
        add_theme_color_override("font_color", Color.RED)
    else:
        add_theme_color_override("font_color", Color.YELLOW)
