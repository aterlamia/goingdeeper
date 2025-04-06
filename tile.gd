@tool
extends Node2D
class_name Tile
var tileWidth: int = 64

@onready var sprite: Sprite2D = get_node('Sprite2D')
var posOnGrid = Vector2(0, 0)

var tiles: Dictionary = {
							"health": {"atlas_coord": Vector2(0, 0), "name": "Health", "value": 10, "type": "buff", "likeliness": 0.05},
							"sword": {"atlas_coord": Vector2(1, 0), "name": "Sword", "value": 5, "type": "weapon", "likeliness": 0.2},
							"shield": {"atlas_coord": Vector2(2, 0), "name": "Shield", "value": 5, "type": "defense", "likeliness": 0.2},
							"coin": {"atlas_coord": Vector2(3, 0), "name": "Coin", "value": 1, "type": "currency", "likeliness": 0.05},
							"damage": {"atlas_coord": Vector2(4, 0), "name": "Damage", "value": 1, "type": "debuff", "likeliness": 0.1},
							"neutral": {"atlas_coord": Vector2(5, 0), "name": "Neutral", "value": 0, "type": "neutral", "likeliness": 0.3},
							"manadark": {"atlas_coord": Vector2(6, 0), "name": "manadark", "value": 0, "type": "manadark", "likeliness": 0.2},
							"manalight": {"atlas_coord": Vector2(7, 0), "name": "manalight", "value": 0, "type": "manalight", "likeliness": 0.2}
						}

var curType: String  = "neutral"
var isDragging: bool = false
var startPosition: Vector2
var mouseOver: bool = false
var maxTilesToMove: int = 1

var hasMoves: bool = true


func _ready() -> void:
	Events.movesFinished.connect(Callable(self, "on_moves_finished"))
	Events.newTurn.connect(Callable(self, "on_new_turn"))
	
func on_moves_finished():
	hasMoves = false
	pass

func on_new_turn():
	hasMoves = true
	pass
	
func getPosFromGrid() -> Vector2:
	var x_pos = position.x / tileWidth
	var y_pos = position.y / tileWidth

	var x_grid_pos = ceil(x_pos) if x_pos > startPosition.x / tileWidth else floor(x_pos)
	var y_grid_pos = ceil(y_pos) if y_pos > startPosition.y / tileWidth else floor(y_pos)

	return Vector2(x_grid_pos, y_grid_pos)
func _input(event) -> void:
	if !hasMoves:
		return
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				if mouseOver:
					isDragging = true
					startPosition = position
					get_parent().highlightPossibleMoves(posOnGrid)
			else:
				if isDragging:
					isDragging = false
					var board: Node                = get_parent()
					var oldPositionOnGrid: Vector2 = posOnGrid
					posOnGrid = getPosFromGrid()
					
					if(posOnGrid == oldPositionOnGrid || posOnGrid.distance_to(oldPositionOnGrid) > maxTilesToMove):
						# If the position hasn't changed, we don't need to swap
						# tiles, just reset the position
						position = startPosition
						posOnGrid = oldPositionOnGrid
						return
					board.swapTiles(oldPositionOnGrid, posOnGrid)
					Events.on_move_made()

	if event is InputEventMouseMotion and isDragging:
		var mouse_pos = get_global_mouse_position()
		# Convert mouse position to local coordinates of the tile's parent
		var local_mouse_pos = get_parent().to_local(mouse_pos)
		var delta = local_mouse_pos - startPosition
		if abs(delta.x) > abs(delta.y):
			position = Vector2(startPosition.x + delta.x, startPosition.y)
		else:
			position = Vector2(startPosition.x, startPosition.y + delta.y)

func setPosOnGrid(pos: Vector2) -> void:
	posOnGrid = pos
	get_node("Label").text = str(posOnGrid)
	get_node("Label/Label").text = str(position)
	
func generateTile() -> void:
	var total_likeliness: float = 0.0
	for tile in tiles.values():
		total_likeliness += tile["likeliness"]

	var random_value: float          = randf() * total_likeliness
	var cumulative_likeliness: float = 0.0

	for tile_name in tiles.keys():
		cumulative_likeliness += tiles[tile_name]["likeliness"]
		if random_value <= cumulative_likeliness:
			setCurType(tile_name)
			break

func getTextureCoord() -> Vector2:
	if tiles.has(curType):
		return tiles[curType]["atlas_coord"]
	else:
		print("Invalid tile type")
		return Vector2(0, 0)

func setCurType(type: String) -> void:
	curType = type
	if tiles.has(curType):
		var tile_data = tiles[curType]
		sprite.texture = preload("res://tiles.png")
		sprite.region_enabled = true
		sprite.region_rect = Rect2(tile_data["atlas_coord"] * tileWidth, Vector2(tileWidth, tileWidth))
	else:
		print("Invalid tile type")


func _on_mouse_entered() -> void:
	print("Mouse entered tile")
	sprite.scale = Vector2(1.1, 1.1)


func _on_mouse_exited() -> void:
	print("Mouse exited tile")
	sprite.scale = Vector2(1, 1)
	
func _on_area_2d_mouse_entered() -> void:
	mouseOver = true
	sprite.scale = Vector2(1.1, 1.1)
	pass # Replace with function body.


func _on_area_2d_mouse_exited() -> void:
	mouseOver = false
	sprite.scale = Vector2(1, 1)
	pass # Replace with function body.
