extends ColorRect

signal upgrade_bought(value)

@onready var upgrade_button: Button = $MarginContainer/VBoxContainer/UpgradeCost
@onready var downstep_button = $MarginContainer/VBoxContainer/HBoxContainer/DownButton
@onready var upstep_button = $MarginContainer/VBoxContainer/HBoxContainer/UpButton
@onready var upgrade_label = $MarginContainer/VBoxContainer/HBoxContainer/UpgradeLabel

var upgrade_level = 0
var upgrade: UpgradeRes

func _ready():
    EventBus.currency_updated.connect(currency_updated)
    upgrade_button.pressed.connect(upgrade_button_pressed)

func init(upgrade: UpgradeRes):
    self.upgrade = upgrade
    $MarginContainer/VBoxContainer/TitleLabel.text = upgrade.name
    upgrade_button.disabled = true
    upstep_button.disabled = true
    downstep_button.disabled = true
    set_upgrade_level(0)

func currency_updated(value):
    upgrade_button.disabled = upgrade.costs[upgrade_level] > value

func upgrade_button_pressed():
    upgrade_bought.emit(upgrade.costs[upgrade_level])
    set_upgrade_level(upgrade_level + 1)
    
func set_upgrade_level(level):
    upgrade_level = level
    upgrade_button.text = "$%s" % Utils.format_num(upgrade.costs[upgrade_level])    
    EventBus.upgrade_level_changed.emit(self)

func set_upgrade_label(text):
    upgrade_label.text = text

func save_data(data: Dictionary):
    data["upgrade_level"] = upgrade_level

func load_data(data: Dictionary):
    set_upgrade_level(data["upgrade_level"])
