extends Node

@onready var _press_registry = load("res://data/presses/press_registry.tres")

var order_types: Dictionary
var press_types: Dictionary

func _ready():
    press_types = {}
    for press_type in _press_registry.presses:
        press_types[press_type.id] = press_type
