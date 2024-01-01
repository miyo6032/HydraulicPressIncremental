extends Node

@onready var upgrade_scene: PackedScene = load("res://upgrade.tscn")
@onready var simulation = $Simulation
@onready var currency_label = $Control/CurrencyLabel
@export var upgrades: Array[UpgradeRes]
@onready var upgrade_container = %Upgrades

var currency = 0
var upgrade_instances = []

var file_load_callback = JavaScriptBridge.create_callback(load_file)

func _ready():
    Console.add_command("save", func(path): save_data("user://" + path + ".res"), 1)
    Console.add_command("load", func(path): load_data("user://" + path + ".res"), 1)
    Console.add_command("v", func(v): update_currency(currency + float(v)), 1)
    EventBus.crushable_removed.connect(crushable_removed)
    if OS.get_name() == "Web":
        var window = JavaScriptBridge.get_interface("window")
        window.getFile(file_load_callback)
    for upgrade in upgrades:
        var upgrade_instance = upgrade_scene.instantiate()
        upgrade_container.add_child(upgrade_instance)
        upgrade_instance.init(upgrade)
        upgrade_instance.upgrade_bought.connect(upgrade_bought)
        upgrade_instances.append(upgrade_instance)

func crushable_removed(crushable):
    update_currency(currency + crushable.get_value())
    
func upgrade_bought(value):
    update_currency(currency - value)
    
func update_currency(value):
    currency = value
    currency_label.text = "$%s" % Utils.format_num(currency)
    EventBus.currency_updated.emit(currency)

func save_data(file_name):
    var game_data = create_save_file()
    var error = ResourceSaver.save(game_data, file_name)
    if error == OK:
        print("saved to " + file_name)
    else:
        print("Error saving graph_data: " + str(error))
        
func create_save_file():
    var game_data = GameData.new()
    game_data.currency = currency
    for instance in upgrade_instances:
        var data = {}
        instance.save_data(data)
        game_data.upgrade_data.append(data)
    return game_data
        
func load_data(file_name):
    if ResourceLoader.exists(file_name):
        var game_data = ResourceLoader.load(file_name)
        if game_data is GameData:
            load_game(game_data)
        else:
            # Error loading data
            pass
    else:
        # File not found
        pass
        
func load_game(game_data):
    update_currency(game_data.currency)
    var i = 0
    for data in game_data.upgrade_data:
        upgrade_instances[i].load_data(data)
        i+=1

const temp_save_file = "user://temp.tres"

func _on_export_save_button_pressed():
    var file = create_save_file()
    ResourceSaver.save(file, temp_save_file)
    download_File(FileAccess.get_file_as_bytes(temp_save_file))
    
func download_File(file):
    JavaScriptBridge.download_buffer(file, "save.txt")

func _on_import_save_button_pressed():
    var window = JavaScriptBridge.get_interface("window")
    window.input.click()
    
func load_file(args):
    var array = args[0].to_utf8_buffer()
    if FileAccess.file_exists(temp_save_file):
        DirAccess.remove_absolute(temp_save_file)
    var file = FileAccess.open(temp_save_file, FileAccess.WRITE)
    file.store_buffer(array)
    file.close()
    var resource = ResourceLoader.load(temp_save_file)
    load_game(resource)
