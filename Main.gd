extends Node

@onready var upgrade_scene: PackedScene = load("res://upgrade.tscn")
@onready var simulation = $Simulation
@onready var currency_label = $Control/CurrencyLabel
@export var upgrades: Array[UpgradeRes]
@onready var upgrade_container = %Upgrades

var currency = 0
var upgrade_instances = []

func _ready():
    Console.add_command("save", func(path): save_data("user://" + path + ".res"), 1)
    Console.add_command("load", func(path): load_data("user://" + path + ".res"), 1)
    Console.add_command("v", func(v): crushable_removed(float(v)), 1)
    EventBus.crushable_removed.connect(crushable_removed)
    for upgrade in upgrades:
        var upgrade_instance = upgrade_scene.instantiate()
        upgrade_container.add_child(upgrade_instance)
        upgrade_instance.init(upgrade)
        upgrade_instance.upgrade_bought.connect(upgrade_bought)
        upgrade_instances.append(upgrade_instance)

func crushable_removed(value):
    update_currency(currency + value)
    
func upgrade_bought(value):
    update_currency(currency - value)
    
func update_currency(value):
    currency = value
    currency_label.text = "$%s" % Utils.format_num(currency)
    EventBus.currency_updated.emit(currency)

func save_data(file_name):
    var game_data = GameData.new()
    game_data.currency = currency
    for instance in upgrade_instances:
        var data = {}
        instance.save_data(data)
        game_data.upgrade_data.append(data)
    
    var error = ResourceSaver.save(game_data, file_name)
    if error == OK:
        print("saved to " + file_name)
    else:
        print("Error saving graph_data: " + str(error))
        
func load_data(file_name):
    if ResourceLoader.exists(file_name):
        var game_data = ResourceLoader.load(file_name)
        if game_data is GameData:
            update_currency(game_data.currency)
            var i = 0
            for data in game_data.upgrade_data:
                upgrade_instances[i].load_data(data)
                i+=1
        else:
            # Error loading data
            pass
    else:
        # File not found
        pass
