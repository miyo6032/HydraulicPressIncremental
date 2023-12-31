extends Node

@onready var upgrade_scene: PackedScene = load("res://upgrade.tscn")
@onready var simulation = $Simulation
@onready var currency_label = $Control/CurrencyLabel
@export var upgrades: Array[UpgradeRes]
@onready var upgrade_container = %Upgrades

var currency = 0

func _ready():
    Console.add_command("v", func(v): crushable_removed(float(v)), 1)
    EventBus.crushable_removed.connect(crushable_removed)
    for upgrade in upgrades:
        var upgrade_instance = upgrade_scene.instantiate()
        upgrade_container.add_child(upgrade_instance)
        upgrade_instance.init(upgrade)
        upgrade_instance.upgrade_bought.connect(upgrade_bought)

func crushable_removed(value):
    update_currency(value)
    
func upgrade_bought(value):
    update_currency(-value)
    
func update_currency(value):
    currency += value
    currency_label.text = "$%s" % Utils.format_num(currency)
    EventBus.currency_updated.emit(currency)
