extends CanvasLayer

var mushrooms: int = 0
var attempts: int = 0

@onready var mushroom_label: Label = $MushroomCounter/MushroomLabel
@onready var attempts_label: Label = $LivesCounter/LivesLabel

func _ready() -> void:
	update_display()

func update_display() -> void:
	mushroom_label.text = "Mushrooms: " + str(mushrooms)
	attempts_label.text = "Lives: " + str(attempts)

func add_mushroom(n: int = 1) -> void:
	mushrooms += n
	update_display()

func record_attempt() -> void:
	attempts += 1
	update_display()
