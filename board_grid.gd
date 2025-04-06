@tool
extends Node2D
class_name BoardGrid
var tileWidth: int = 64
@export var tilesH: int = 8	
@export var tilesW: int = 8
var tiles: Array = []
var highlight_color: Color = Color(1, 1, 0, 0.5) # Yellow with 50% opacity
var texture: Texture2D = preload("res://tiles.png")

@onready var highLighter: Node2D = get_node("HighLighter")	
func _ready() -> void:
	generateBoard()
	highLighter.visible = false


func generateBoard() -> void:
	for i in range(tilesH):
		tiles.append([])
		for j in range(tilesW):
			var tile_instance = Sprite2D.new()
			tile_instance.texture = texture
			tile_instance.region_enabled = true

			# Alternate between tile1 and tile2
			if (i + j) % 2 == 0:
				tile_instance.region_rect = Rect2(Vector2(0, 8) * tileWidth, Vector2(tileWidth, tileWidth))
			else:
				tile_instance.region_rect = Rect2(Vector2(1, 8) * tileWidth, Vector2(tileWidth, tileWidth))

			tile_instance.position = Vector2(j * tileWidth, i * tileWidth)
			add_child(tile_instance)
			tiles[i].append(tile_instance)

func highlightPossibleMoves(tile_pos: Vector2) -> void:
	highLighter.visible = true
	highLighter.position = tile_pos * tileWidth
