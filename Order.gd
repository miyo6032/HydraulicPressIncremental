extends Control


signal claimed
signal unlocked

@onready var order_desc = $MarginContainer/HBoxContainer/VBoxContainer/OrderLabel
@onready var claim_button = $MarginContainer/HBoxContainer/ClaimButton
@onready var progress_bar = $MarginContainer/HBoxContainer/VBoxContainer/ProgressBar
@onready var progress_label = $MarginContainer/HBoxContainer/VBoxContainer/ProgressBar/ProgressLabel
@onready var image = $MarginContainer/HBoxContainer/Image

var count
var current_order: OrderRes

func _ready():
    EventBus.crushable_removed.connect(crushable_removed)
    progress_bar.max_value = 1
    claim_button.pressed.connect(claim_button_pressed);

func set_order(order: OrderRes):
    order_desc.text = order.get_description()
    claim_button.text = "Reward: $" + Utils.format_num(order.currency)
    if order.shape_constraint:
        image.visible = true        
        image.texture = order.shape_constraint.texture
        var material: ShaderMaterial = image.material        
        if order.pattern_constraint:
            material.set_shader_parameter("MainTex", order.pattern_constraint.texture)
        else:
            material.set_shader_parameter("MainTex", null)
    else:
        image.visible = false
    current_order = order
    claim_button.disabled = true
    update_count(0)

func crushable_removed(crushable):
    if current_order.counts_towards_order(crushable):
        update_count(clamp(count + 1, 0, current_order.amount))

func update_count(new_count):
    count = new_count
    progress_bar.value = count / float(current_order.amount)
    progress_label.text = "%.0f/%.0f" % [count, current_order.amount]
    if count >= current_order.amount:
        claim_button.disabled = false
        claim_button.text = "Claim: $" + Utils.format_num(current_order.currency)
        unlocked.emit()

func claim_button_pressed():
    claimed.emit()

func save_data(data):
    data["count"] = count
    data["current_order"] = current_order.id

func load_data(data):
    set_order(Registries.order_types[data["current_order"]])
    update_count(data["count"])
