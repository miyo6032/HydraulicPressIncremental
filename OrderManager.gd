extends ColorRect

signal order_finished(order)

@export var order_list: OrderList
@export var order_uis: Array[Control]

var next_order = 0

func _ready():
    for ui in order_uis:
        ui.set_order(order_list.orders[next_order])
        ui.claimed.connect(claimed.bind(ui))
        next_order += 1

func claimed(ui):
    order_finished.emit(ui.current_order)
    ui.set_order(order_list.orders[next_order])
    next_order += 1

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
    var i = 0
    for order_data in data["current_orders"]:
        order_uis[i].load_data(order_data)
        i+=1