extends ColorRect

@export var order_list: OrderList
@export var order_uis: Array[Control]

var next_order = 0

func _ready():
    for ui in order_uis:
        ui.set_order(order_list.orders[next_order])
        next_order += 1
    
func save_data(data: Dictionary):
    pass
    
func load_data():
    pass
