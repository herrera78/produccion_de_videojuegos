extends Area2D

@onready var sprite: Sprite2D = $Sprite2D

func activate():
	sprite.modulate = Color(1.0, 0.5, 0.3)

func deactivate():
	sprite.modulate = Color.WHITE
