extends Label


func _ready():
    EventBus.current_force_changed.connect(current_force_changed)
    
func current_force_changed(force):
    text = "%.2f tons" % force
