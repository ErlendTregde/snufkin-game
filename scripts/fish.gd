extends Node2D

@onready var area = $Area2D  

func _ready():
	add_to_group("fish")  
	print("🐟 Fish initialized:", name)
