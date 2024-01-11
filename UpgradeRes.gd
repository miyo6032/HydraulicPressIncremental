extends Resource

class_name UpgradeRes

@export var name: String
@export var upgrade_value: float
@export var upgrade_type: Enums.UpgradeType
@export var tooltip: String
@export var costs: Array[float]
var max_level: int:
    get:
        return costs.size()
