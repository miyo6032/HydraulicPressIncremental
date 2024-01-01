extends ColorRect

@onready var order_desc = $MarginContainer/HBoxContainer/VBoxContainer/OrderLabel
@onready var claim_button = $MarginContainer/HBoxContainer/ClaimButton
@onready var progress_bar = $MarginContainer/HBoxContainer/VBoxContainer/ProgressBar
@onready var progress_label = $MarginContainer/HBoxContainer/VBoxContainer/ProgressBar/ProgressLabel

var count
var current_order: OrderRes

func _ready():
    EventBus.crushable_removed.connect(crushable_removed)
    progress_bar.max_value = 1

func set_order(order: OrderRes):
    order_desc.text = order.get_description()
    claim_button.text = "Reward: $" + Utils.format_num(order.amount)
    current_order = order
    claim_button.disabled = true
    update_count(0)

func crushable_removed(crushable):
    if current_order.counts_towards_order(crushable):
        update_count(clamp(count + 1, 0, current_order.amount))

func update_count(new_count):
    count = new_count
    progress_bar.value = count / current_order.amount
    progress_label.text = "%.0f/%.0f" % [count, current_order.amount]        
    if count >= current_order.amount:
        claim_button.disabled = false
        claim_button.text = "Claim: $" + Utils.format_num(current_order.amount)

func save_data():
    pass
    
func load_data():
    pass
