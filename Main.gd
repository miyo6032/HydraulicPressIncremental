extends Node

const temp_save_file = "user://temp.tres"

var file_load_callback = JavaScriptBridge.create_callback(load_file)
@onready var current_run_scene = load("res://current_run.tscn")
var current_run

func _ready():
    Console.add_command("save", func(path): save_data("user://" + path + ".res"), 1)
    Console.add_command("load", func(path): load_data("user://" + path + ".res"), 1)
    Console.add_command("time", func(time): Engine.time_scale = float(time), 1)
    if OS.get_name() == "Web":
        var window = JavaScriptBridge.get_interface("window")
        window.getFile(file_load_callback)
    current_run = current_run_scene.instantiate()
    add_child(current_run)
    EventBus.new_press_selected.connect(reset_with_press)
    EventBus.terminal_crush.connect(func(): get_tree().paused = true)
    
func reset_with_press(press_res):
    EventBus.press_selected.emit(press_res)
    var persistent_game_data = current_run.create_persistent_save_file()
    current_run.queue_free()
    current_run = current_run_scene.instantiate()
    add_child(current_run)
    current_run.load_from_persistent_save_file(persistent_game_data)
    var game_data = current_run.create_save_file()
    current_run.queue_free()
    current_run = current_run_scene.instantiate()
    add_child(current_run)
    current_run.load_game(game_data)
    get_tree().paused = false

func _on_export_save_button_pressed():
    var file = current_run.create_save_file()
    ResourceSaver.save(file, temp_save_file)
    download_File(FileAccess.get_file_as_bytes(temp_save_file))

func save_data(file_name):
    var game_data = current_run.create_save_file()
    var error = ResourceSaver.save(game_data, file_name)
    if error == OK:
        print("saved to " + file_name)
    else:
        print("Error saving graph_data: " + str(error))
        
func load_data(file_name):
    if ResourceLoader.exists(file_name):
        var game_data = ResourceLoader.load(file_name)
        if game_data is GameData:
            current_run.load_game(game_data)
        else:
            # Error loading data
            pass
    else:
        # File not found
        pass

func load_file(args):
    var array = args[0].to_utf8_buffer()
    if FileAccess.file_exists(temp_save_file):
        DirAccess.remove_absolute(temp_save_file)
    var file = FileAccess.open(temp_save_file, FileAccess.WRITE)
    file.store_buffer(array)
    file.close()
    var resource = ResourceLoader.load(temp_save_file)
    current_run.load_game(resource)
    
func download_File(file):
    JavaScriptBridge.download_buffer(file, "save.txt")

func _on_import_save_button_pressed():
    var window = JavaScriptBridge.get_interface("window")
    window.input.click()
