@tool
extends Node2D
class_name Board

var tilesH: int = 8
var tilesW: int = 8
var tileWidth: int = 64
var tileScene: PackedScene = preload("res://tile.tscn")
var ScoreParticle: PackedScene = preload("res://ScoreParticle.tscn")
var ExplodeParticle: PackedScene = preload("res://ExpolideParticle.tscn")
var tiles: Array = []
@onready var boardGrid: BoardGrid = get_node("BoardGrid")
@export var player: Player
func _ready() -> void:
	
	# Initialize the board with tiles
	for i in range(tilesH):
		tiles.append([])
		for j in range(tilesW):
			var tile_instance: Tile = tileScene.instantiate()
			tile_instance.position = Vector2(j * tileWidth, i * tileWidth)
			add_child(tile_instance)
			tile_instance.generateTile()
			tile_instance.setPosOnGrid(Vector2(j, i))
			tiles[i].append(tile_instance)
	# Check for initial matches
	# This is a workaround to ensure that the initial state of the board has no matches
	# by replacing the tiles with new ones if there are any matches
	# if checkMatch returs true we check again a max of 50 times
	var attempts = 0
	while attempts < 50:
		attempts += 1
		print("Found a match at attemt " + str(attempts) + " replacing tiles")
		if !checkMatch(true):
			break
	console()

	
func console() -> void:
	Console.pause_enabled = true
	# Print the current state of the board
	Console.add_hidden_command("removetile",console_remove_tile, ["x", "y"], 2)
	
	
func console_remove_tile(x:Variant, y:Variant):
	var pos = Vector2(int(x), int(y))
	# Remove a tile at the specified position
	if pos.x >= 0 and pos.x < tilesW and pos.y >= 0 and pos.y < tilesH:
		var tile: Tile = tiles[pos.y][pos.x]
		remove_child(tile)
		tiles[pos.y][pos.x] = null
		#get tile above the removed tile and move it down to fill the gap
		for i in range(pos.y - 1, -1, -1):
			if tiles[i][pos.x] != null:
				tiles[i][pos.x].setPosOnGrid(Vector2(pos.x, pos.y))
				tiles[pos.y][pos.x] = tiles[i][pos.x]
				tiles[i][pos.x] = null
				animateTileFall(tiles[pos.y][pos.x], Vector2(pos.x, pos.y))
				break
	else:
		print("Invalid position")

func checkMatch(isInitial: bool = false):
	var hadMatch = false

	# Check for horizontal matches
	for i in range(tilesH):
		var j = 0
		while j < tilesW:
			var current_type = tiles[i][j].curType
			var matched_positions = [Vector2(i, j)]

			# Check consecutive tiles of the same type in this row
			var k = j + 1
			while k < tilesW and tiles[i][k].curType == current_type:
				matched_positions.append(Vector2(i, k))
				k += 1

			# If we found a match (3 or more consecutive tiles)
			if matched_positions.size() >= 3:
				hadMatch = tilesMatched(isInitial, matched_positions, current_type)
				j = k  # Skip the matched tiles
			else:
				j += 1  # Move to the next tile

	# Check for vertical matches
	for j in range(tilesW):
		var i = 0
		while i < tilesH:
			var current_type = tiles[i][j].curType
			var matched_positions = [Vector2(i, j)]

			# Check consecutive tiles of the same type in this column
			var k = i + 1
			while k < tilesH and tiles[k][j].curType == current_type:
				matched_positions.append(Vector2(k, j))
				k += 1

			# If we found a match (3 or more consecutive tiles)
			if matched_positions.size() >= 3:
				hadMatch = tilesMatched(isInitial, matched_positions, current_type)
				i = k  # Skip the matched tiles
			else:
				i += 1  # Move to the next tile
	if(!hadMatch):
		Events.on_no_matches_found()
			
	return hadMatch

func tilesMatched(isInitial: bool, matched_positions: Array, curType: String) -> bool:
	if isInitial:
		replaceTiles(matched_positions)
		return true
	else:
		get_node('Expolode').play()
		animateTiles(matched_positions)
		scoreTiles( curType, matched_positions.size())
		removeTiles(matched_positions)
	return false
		
func animateTiles(positions: Array) -> void:
	for pos in positions:
		var tile: Tile = tiles[pos.x][pos.y]
		# for each tile create a tween and a node of the type ScoreParticle animate it from the tile position to the player position after that destroy the tween and the particle
		var tween = create_tween()
		
		
		var explde_particle: CPUParticles2D = ExplodeParticle.instantiate()
		explde_particle.position = tile.position
		explde_particle.emitting = true
		add_child(explde_particle)
		explde_particle.finished.connect(func():
			remove_child(explde_particle)
			explde_particle.queue_free()
		)
	
		var score_particle = ScoreParticle.instantiate()
		score_particle.position = tile.position
		score_particle.set_tile(tile)
		add_child(score_particle)
		var target_position = to_local(player.global_position)
		tween.tween_property(score_particle, "position", target_position, 0.7)
		# after the tween is done remove the particle and the tween
		tween.finished.connect(func():
			remove_child(score_particle)
			score_particle.queue_free()
		)
		

func replaceTiles(positions: Array) -> void:
	for pos in positions:
		var tile: Tile = tiles[pos.x][pos.y]
		tile.generateTile()
		
func removeTiles(positions: Array) -> void:
	for pos in positions:
		var tile: Tile = tiles[pos.x][pos.y]
		remove_child(tile)
		tiles[pos.x][pos.y] = null
	refillGrid()

func refillGrid() -> void:
	var animation_tracker: Dictionary = {
								"pending": 0,
								"completed": 0
							}

	for j in range(tilesW):
		for i in range(tilesH - 1, -1, -1):
			if tiles[i][j] == null:
				for k in range(i - 1, -1, -1):
					if tiles[k][j] != null:
						animation_tracker.pending += 1
						break
	
		for i in range(tilesH):
				if tiles[i][j] == null:
					animation_tracker.pending += 1
	
	# If no animations will run, check matches immediately
	if animation_tracker.pending == 0:
		checkMatch()
		return

	var check_when_done = func():
		animation_tracker.completed += 1
		if animation_tracker.completed >= animation_tracker.pending:
			checkMatch()

	for j in range(tilesW):
		for i in range(tilesH - 1, -1, -1):
			if tiles[i][j] == null:
				for k in range(i - 1, -1, -1):
					if tiles[k][j] != null:
						tiles[i][j] = tiles[k][j]
						tiles[k][j] = null
						tiles[i][j].setPosOnGrid(Vector2(j, i))
						animateTileFall(tiles[i][j], Vector2(j, i), check_when_done)
						break
		var newTilesInner: int = 0	
		for i in range(tilesH):
			if tiles[i][j] == null:
				newTilesInner += 1
			
		for i in range(tilesH):
			if tiles[i][j] == null:
				var tile_instance: Tile = tileScene.instantiate()
				tile_instance.position = Vector2(j * tileWidth, -tileWidth * ((newTilesInner-i))) # Start above the grid
				add_child(tile_instance)
				tile_instance.generateTile()
				tile_instance.setPosOnGrid(Vector2(j, i))
				tiles[i][j] = tile_instance
				animateTileFall(tile_instance, Vector2(j, i), check_when_done)

func animateTileFall(tile: Tile, target_pos: Vector2, callback = null) -> void:
	var tween = create_tween()
	var target_position = target_pos * tileWidth

	tween.set_trans(Tween.TRANS_BOUNCE)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(tile, "position", target_position, 0.8)

	if callback:
		tween.finished.connect(callback)
	
func scoreTiles(type: String, amount:int) -> void:
	Events.on_match_made(type, amount)
	pass
	
	
func highlightPossibleMoves(tile_pos):
	boardGrid.highlightPossibleMoves(tile_pos)

func swapTiles(start_pos: Vector2, end_pos: Vector2) -> void:
	if start_pos == end_pos:
			return

		
	if end_pos.x >= 0 and end_pos.x < tilesW and end_pos.y >= 0 and end_pos.y < tilesH:
		var temp: Tile = tiles[start_pos.y][start_pos.x]
		tiles[start_pos.y][start_pos.x] = tiles[end_pos.y][end_pos.x]
		tiles[end_pos.y][end_pos.x] = temp
		temp.setPosOnGrid(end_pos)
		tiles[start_pos.y][start_pos.x].setPosOnGrid(start_pos)


		tiles[start_pos.y][start_pos.x].position = start_pos * tileWidth
		tiles[end_pos.y][end_pos.x].position = end_pos * tileWidth
		
	checkMatch()
	
