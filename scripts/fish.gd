extends PathFollow2D

@export var speed: float = 100.0  

@onready var area = $Area2D  # Reference to Area2D

func _ready():
	area.connect("area_entered", Callable(self, "_on_area_entered"))

func _process(delta):
	progress += speed * delta  
	if progress_ratio >= 1.0:  
		queue_free()

func _on_area_entered(area):
	print("🐟 Fish collided with:", area.name, " | Parent:", area.get_parent().name)

func _on_area_2d_area_entered(area: Area2D) -> void:
	pass # Replace with function body.
