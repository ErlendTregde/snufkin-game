extends Control
# Achievement notification popup - Moomin themed

@onready var icon_label = $Panel/MarginContainer/HBox/IconLabel
@onready var title_label = $Panel/MarginContainer/HBox/VBox/TitleLabel
@onready var desc_label = $Panel/MarginContainer/HBox/VBox/DescLabel
@onready var panel = $Panel

var tween: Tween

func _ready():
	modulate.a = 0
	position.y -= 100
	
	# Listen for achievement unlocks
	FishingData.achievement_unlocked.connect(_on_achievement_unlocked)

func _on_achievement_unlocked(achievement_id: String):
	var ach_data = FishingData.get_achievement_progress(achievement_id)
	show_notification(ach_data)

func show_notification(achievement_data: Dictionary):
	# Set content
	icon_label.text = achievement_data.get("icon", "✨")
	title_label.text = achievement_data.get("name", "Achievement Unlocked")
	desc_label.text = achievement_data.get("description", "")
	
	# Animate in
	if tween:
		tween.kill()
	
	tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(self, "modulate:a", 1.0, 0.5).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "position:y", position.y + 100, 0.5).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	
	# Wait and animate out
	await get_tree().create_timer(4.0).timeout
	
	tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(self, "modulate:a", 0.0, 0.5).set_ease(Tween.EASE_IN)
	tween.tween_property(self, "position:y", position.y - 100, 0.5).set_ease(Tween.EASE_IN)
