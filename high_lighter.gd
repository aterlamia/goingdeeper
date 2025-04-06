@tool
extends Node2D

@onready var topPanel: Panel = get_node("Top")
@onready var bottomPanel: Panel = get_node("Bottom")
@onready var leftPanel: Panel = get_node("Left")
@onready var rightPanel: Panel = get_node("Right")
@onready var midPanel: Panel = get_node("Middle")

@export var border_width: int = 2:
	set(new_border_width):
		border_width = new_border_width
		update_panels_after_set()
@export var border_color: Color = Color(1, 0, 0):
	set(new_border_color):
		border_color = new_border_color
		update_panels_after_set()
@export var panel_color: Color = Color(0, 1, 0):
	set(new_panel_color):
		panel_color = new_panel_color
		update_panels_after_set()

func _ready() -> void:
	update_panels()

func update_panels_after_set() -> void:
	if Engine.is_editor_hint():
		update_panels()
		
func update_panels() -> void:
	set_panel_style(topPanel, border_width, border_color, panel_color, ["top", "left", "right"])
	set_panel_style(bottomPanel, border_width, border_color, panel_color, ["bottom", "left", "right"])
	set_panel_style(leftPanel, border_width, border_color, panel_color, ["top", "bottom", "left"])
	set_panel_style(rightPanel, border_width, border_color, panel_color, ["top", "bottom", "right"])
	set_panel_style(midPanel, 0, border_color, panel_color, []) # No borders for the middle panel

	
func set_panel_style(panel: Panel, border_width: int, border_color: Color, panel_color: Color, borders: Array) -> void:
	var stylebox = StyleBoxFlat.new()
	stylebox.bg_color = panel_color
	stylebox.border_blend = true

	if "top" in borders:
		stylebox.border_width_top = border_width
	if "bottom" in borders:
		stylebox.border_width_bottom = border_width
	if "left" in borders:
		stylebox.border_width_left = border_width
	if "right" in borders:
		stylebox.border_width_right = border_width

	stylebox.border_color = border_color
	panel.add_theme_stylebox_override("panel", stylebox)
