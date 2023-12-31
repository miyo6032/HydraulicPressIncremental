extends Node

@onready var simulation = $Simulation
@onready var currency_label = $Control/CurrencyLabel

var currency = 0

func _ready():
    EventBus.crushable_removed.connect(crushable_removed)

func crushable_removed(value):
    currency += value
    currency_label.text = "$%s" % comma_sep(currency)
    
static func comma_sep(n: int) -> String:
    var result := ""
    var i: int = abs(n)
    
    while i > 999:
        result = ",%03d%s" % [i % 1000, result]
        i /= 1000
    
    return "%s%s%s" % ["-" if n < 0 else "", i, result]
