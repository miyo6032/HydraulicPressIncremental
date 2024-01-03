extends Node

@onready var _order_list_registry = load("res://data/order_list.tres")
@onready var _press_registry = load("res://data/presses/press_registry.tres")

var order_types: Dictionary
var press_types: Dictionary

func _ready():
    order_types = {}
    for order_type in _order_list_registry.orders:
        order_types[order_type.id] = order_type
    
    press_types = {}
    for press_type in _press_registry.presses:
        press_types[press_type.id] = press_type
