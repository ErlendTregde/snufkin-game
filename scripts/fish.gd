extends PathFollow2D

@export var speed: float = 100.0  # Fish movement speed

func _process(delta):
	progress += speed * delta  # Move fish along path

	if progress_ratio >= 1.0:  
		queue_free()  # Remove fish when it reaches the bottom
