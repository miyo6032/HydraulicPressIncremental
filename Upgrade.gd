extends ColorRect

signal upgrade_bought(value)

@onready var upgrade_button: Button = $MarginContainer/VBoxContainer/UpgradeCost
@onready var downstep_button = $MarginContainer/VBoxContainer/HBoxContainer/DownButton
@onready var upstep_button = $MarginContainer/VBoxContainer/HBoxContainer/UpButton
@onready var upgrade_label = $MarginContainer/VBoxContainer/HBoxContainer/UpgradeLabel

var current_upgrade_level = 0
var max_upgrade_level = 0
var upgrade: UpgradeRes

func _ready():
    EventBus.currency_updated.connect(currency_updated)
    upgrade_button.pressed.connect(upgrade_button_pressed)
    downstep_button.pressed.connect(downstep_button_pressed)
    upstep_button.pressed.connect(upstep_button_pressed)

func init(upgrade: UpgradeRes):
    self.upgrade = upgrade
    var title = $MarginContainer/VBoxContainer/TitleLabel
    title.tooltip_text = upgrade.tooltip
    title.text = upgrade.name
    upgrade_button.disabled = true
    set_max_upgrade_level(0)

func currency_updated(value):
    upgrade_button.disabled = upgrade.costs[max_upgrade_level] > value

func upgrade_button_pressed():
    upgrade_bought.emit(upgrade.costs[max_upgrade_level])
    set_max_upgrade_level(max_upgrade_level + 1)
    
func upstep_button_pressed():
    current_upgrade_level = clamp(current_upgrade_level + 1, 0, max_upgrade_level)    
    current_level_changed()

func downstep_button_pressed():
    current_upgrade_level = clamp(current_upgrade_level - 1, 0, max_upgrade_level)
    current_level_changed()
    
func update_step_button_enablements():
    upstep_button.disabled = current_upgrade_level == max_upgrade_level
    downstep_button.disabled = current_upgrade_level == 0
    
func set_max_upgrade_level(level):
    max_upgrade_level = level
    upgrade_button.text = "$%s" % Utils.format_num(upgrade.costs[max_upgrade_level])
    current_upgrade_level = max_upgrade_level
    current_level_changed()
    
func current_level_changed():
    update_step_button_enablements()
    EventBus.upgrade_level_changed.emit(self)

func set_upgrade_label(text):
    upgrade_label.text = text

func save_data(data: Dictionary):
    data["max_upgrade_level"] = max_upgrade_level
    data["current_upgrade_level"] = current_upgrade_level

func load_data(data: Dictionary):
    current_upgrade_level = data["current_upgrade_level"]    
    set_max_upgrade_level(data["max_upgrade_level"])
