# res://src/scenes/menu/menu_panel.gd
extends Control
@onready var btn_exit: Button = $VBoxMenu/BtnExit

func _ready() -> void:
	btn_exit.pressed.connect(func() -> void:
		get_tree().quit()
	)
