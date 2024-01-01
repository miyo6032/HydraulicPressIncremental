extends ColorRect

@onready var order_desc = $MarginContainer/HBoxContainer/VBoxContainer/OrderLabel
@onready var claim_button = $MarginContainer/HBoxContainer/ClaimButton

func set_order(order: OrderRes):
    order_desc.text = order.get_description()
    claim_button.text = "Reward: $" + Utils.format_num(order.amount)
