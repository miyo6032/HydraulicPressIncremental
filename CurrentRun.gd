extends Node

@onready var upgrade_scene: PackedScene = load("res://upgrade.tscn")
@onready var simulation = $Simulation
@onready var currency_label = %CurrencyLabel
@export var upgrades: Array[UpgradeRes]
@onready var upgrade_container = %Upgrades
@onready var order_manager = %OrderManager
@onready var change_press_button = %ChangePressButton
@onready var change_press_menu = $CanvasLayer/Control/ChangePressMenu

var currency = 0
var upgrade_instances = []
var hmmge: Array[PressRes]
var unlocked_presses: Array[PressRes]:
    get:
        return hmmge
    set(value):
        hmmge = value
        change_press_button.visible = hmmge.size() > 1
        
func _ready():
    unlocked_presses = [load("res://data/presses/press.tres")]
    Console.add_command("v", func(v): update_currency(currency + float(v)), 1)
    EventBus.crushable_removed.connect(crushable_removed)
    EventBus.new_press_selected.connect(func(press): unlocked_presses.append(press))
    order_manager.order_finished.connect(order_manager_order_finished)
    change_press_button.pressed.connect(change_press_button_pressed)
    for upgrade in upgrades:
        var upgrade_instance = upgrade_scene.instantiate()
        upgrade_container.add_child(upgrade_instance)
        upgrade_instance.init(upgrade)
        upgrade_instance.upgrade_bought.connect(upgrade_bought)
        upgrade_instances.append(upgrade_instance)

func change_press_button_pressed():
    change_press_menu.load(unlocked_presses)

func crushable_removed(crushable):
    update_currency(currency + crushable.get_value())
    
func upgrade_bought(value):
    update_currency(currency - value)
    
func update_currency(value):
    currency = value
    currency_label.text = "$%s" % Utils.format_currency(currency)
    EventBus.currency_updated.emit(currency)
    
func order_manager_order_finished(order):
    update_currency(currency + order.currency)

func create_save_file():
    var game_data = GameData.new()
    game_data.currency = currency
    for instance in upgrade_instances:
        var data = {}
        instance.save_data(data)
        game_data.upgrade_data.append(data)
    order_manager.save_data(game_data.orders_data)
    simulation.save_data(game_data.simulation_data)
    game_data.unlocked_presses = unlocked_presses      
    return game_data

func load_game(game_data):
    unlocked_presses = game_data.unlocked_presses    
    simulation.load_data(game_data.simulation_data)
    order_manager.load_data(game_data.orders_data)    
    var i = 0
    for data in game_data.upgrade_data:
        upgrade_instances[i].load_data(data)
        i+=1
    update_currency(game_data.currency)
    
func create_persistent_save_file():
    var game_data = GameData.new()
    simulation.save_data(game_data.simulation_data)
    game_data.unlocked_presses = unlocked_presses  
    return game_data
    
func load_from_persistent_save_file(game_data):
    unlocked_presses = game_data.unlocked_presses    
    simulation.load_data(game_data.simulation_data)
