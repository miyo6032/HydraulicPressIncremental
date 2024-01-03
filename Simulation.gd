extends Node2D

@onready var press = $Press
@onready var conveyor = $Conveyor

func _ready():
    Console.add_command("crush", func(): press.crush(conveyor.get_current_crushable()))
    press.crush_finished.connect(crush_finished)
    conveyor.move_finished.connect(move_finished)
    start()

func start():
    conveyor.move_conveyor()
    
func move_finished():
    if conveyor.has_current_crushable():
        press.crush(conveyor.get_current_crushable())
    else:
        conveyor.move_conveyor()        

func crush_finished():
    conveyor.move_conveyor()    
    
func save_data(data):
    conveyor.save_data(data)
    press.save_data(data)
    
func load_data(data):
    conveyor.load_data(data)
    press.load_data(data)    
