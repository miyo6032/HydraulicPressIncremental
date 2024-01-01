extends Label


func _ready():
    EventBus.current_force_changed.connect(current_force_changed)
    
func current_force_changed(force):
    text = "Current force: %.2f tons" % force
