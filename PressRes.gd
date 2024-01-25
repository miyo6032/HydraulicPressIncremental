extends Resource

class_name PressRes

@export var name: String
@export var description: String
@export var texture: Texture2D
@export var press_particles: PackedScene
@export var minimum_presses_unlocked: int = 1
@export var force_upgrade: float = 1
@export var precision_upgrade: float = 0
@export var speed_upgrade: float = 0
@export var quality_upgrade: float = 0
@export var hydraulic_force_upgrade: float = 1
@export var hydraulic_speed_downgrade: float = 1
var id:
    get:
        return resource_path
