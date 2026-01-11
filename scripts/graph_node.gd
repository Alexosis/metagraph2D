extends Area2D
class_name Graph_Node

signal moved(id: int, new_pos: Vector2)

@export var node_id: int
@export var radius := 20.0:
	set(value):
		radius = value
		_update_collision()

@onready var collision: CollisionShape2D = $NodeCollision

func _ready():
	_update_collision()

func _update_collision():
	if collision == null:
		return
	var shape := collision.shape
	if shape is CircleShape2D:
		shape.radius = radius

func _draw():
	draw_circle(Vector2.ZERO, radius, Color.CORNFLOWER_BLUE)

@onready var node_lable: Label = $NodeName 

func set_text(value: String):
	node_lable.text = value

var dragging := false
var drag_offset := Vector2.ZERO

func _stop_drag():
	dragging = false
	set_process_input(false)

func _input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			dragging = true
			drag_offset = global_position - event.global_position
			set_process_input(true)
		else:
			_stop_drag()

func _input(event):
	if not dragging:
		return
	if event is InputEventMouseMotion:
		global_position = event.global_position + drag_offset
		moved.emit(node_id, global_position)
	elif event is InputEventMouseButton and not event.pressed:
		_stop_drag()
