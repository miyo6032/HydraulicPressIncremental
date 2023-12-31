extends Node2D

@onready var press = $Press
@onready var conveyor = $Conveyor

func _ready():
    Console.add_command("crush", func(): press.crush(null))
