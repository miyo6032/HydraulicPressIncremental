extends CPUParticles2D

func _ready():
    await finished
    queue_free()
