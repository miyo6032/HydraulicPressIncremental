extends Node

@onready var _order_list_registry = load("res://data/order_list.tres")

var order_types: Dictionary

func _ready():
    order_types = {}
    for order_type in _order_list_registry.orders:
        order_types[order_type.id] = order_type
