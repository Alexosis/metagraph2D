extends Panel
class_name NodeDetail

@onready var name_label: Label = $MarginContainer/VBoxContainer/HBoxContainer/Name
@onready var type_label: Label = $MarginContainer/VBoxContainer/Type
@onready var description: RichTextLabel = $MarginContainer/VBoxContainer/Description
@onready var close_button: Button = $MarginContainer/VBoxContainer/HBoxContainer/ClosePanelDetailButton

func show_data(data: Dictionary):
	print(data)
	name_label.text = data.get("NodeName", "—")
	type_label.text = data.get("type", "—")
	description.text = data.get("description", "")
	print(description.text)
	show()

func _ready():
	hide()
	close_button.pressed.connect(hide)
