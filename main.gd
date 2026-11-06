extends Node2D
@onready var camera_a: Camera2D = $RoomA/CameraA
@onready var camera_b: Camera2D = $RoomB/CameraB
@onready var btn_camera_a: Button = $UI/BtnCameraA
@onready var btn_camera_b: Button = $UI/BtnCameraB

func animate_camera_a() -> void:
	var tween := create_tween().set_loops()

	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_IN_OUT)

	tween.tween_property(camera_a, "position:x", -480.0, 4.0)
	tween.tween_property(camera_a, "position:x", 480.0, 4.0)
	

func animate_camera_b() -> void:
	var tween := create_tween().set_loops()

	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_IN_OUT)

	tween.tween_property(camera_b, "position:x", -480.0, 5.0)
	tween.tween_property(camera_b, "position:x", 480.0, 5.0)
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	animate_camera_a()
	animate_camera_b()
	btn_camera_a.pressed.connect(_on_camera_a_pressed)
	btn_camera_b.pressed.connect(_on_camera_b_pressed)

func _on_camera_a_pressed() -> void:
	camera_a.enabled = true
	camera_b.enabled = false


func _on_camera_b_pressed() -> void:
	camera_a.enabled = false
	camera_b.enabled = true
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
