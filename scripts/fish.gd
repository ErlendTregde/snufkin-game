extends PathFollow2D

@export var speed: float = 100.0  # Fish movement speed

func _process(delta):
	progress += speed * delta  # Move fish along path

	if progress_ratio >= 1.0:  # If fish reaches the end of the path
		print("❌ Fish Reached End & Queued for Removal!")
		queue_free()  # Schedule fish for removal
