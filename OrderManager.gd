extends Control

signal order_finished(order)

@export var order_uis: Array[Control]
@onready var fade_ui = $FadeUI
@onready var shape_list: ShapeList = load("res://data/shape_list.tres")
@onready var order_list: OrderList = load('res://data/order_list.tres')

var current_material_level
var max_material_level
var next_order = 0

func _ready():
    EventBus.upgrade_level_changed.connect(upgrade_level_changed)
    for ui in order_uis:
        get_next_order(ui)
        ui.claimed.connect(claimed.bind(ui))
        ui.unlocked.connect(func(): fade_ui.fade_in_if_not_active())
    
func get_next_order(ui):
    if next_order < order_list.orders.size():
        ui.set_order(order_list.orders[next_order])
        next_order += 1
    else:
        ui.set_order(generate_order())

func upgrade_level_changed(instance):
    if instance.upgrade.upgrade_type == Enums.UpgradeType.Materials:
        current_material_level = instance.current_upgrade_level
        max_material_level = instance.max_upgrade_level
        
func claimed(ui):
    order_finished.emit(ui.current_order)
    get_next_order(ui)
    
func generate_order():
    var order = OrderRes.new()
    order.amount = randi_range(5, 15)
    order.shape_constraint = shape_list.shapes[max_material_level]
    order.pattern_constraint = order.shape_constraint.possible_patterns[randi_range(0, order.shape_constraint.possible_patterns.size() - 1)]
    order.currency = order.shape_constraint.value_multiplier * order.pattern_constraint.value_multiplier * order.amount * 4
    return order

func save_data(data: Dictionary):
    data["next_order"] = next_order
    var current_orders = []
    for ui in order_uis:
        var order_data = {}
        ui.save_data(order_data)
        current_orders.append(order_data)
    data["current_orders"] = current_orders
    
func load_data(data: Dictionary):
    next_order = data["next_order"]
    if next_order > 3:
        fade_ui.show_instantly()
    var i = 0
    for order_data in data["current_orders"]:
        order_uis[i].load_data(order_data)
        i+=1
