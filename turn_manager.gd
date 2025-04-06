extends Node
class_name TurnManager

var enemies : Array = []

var availableMoves: int = 3
var movesMade: int = 0
@onready var player: Player = get_node("Player")
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#get the children of the node Enemies and add them to the enemies array
	for child in get_node("Enemies").get_children():
		if child is Enemy:
			enemies.append(child)
		
	Events.levelStarted.connect(Callable(self, "on_level_started"))
	Events.moveMade.connect(Callable(self, "on_move_made"))
	player.attackDone.emit(Callable(self, "on_player_attack_done"))
	pass # Replace with function body.

	
func on_player_attack_done() -> void:
	movesMade = 0
	Events.on_new_turn()
	get_node('Moves').text = str(availableMoves - movesMade)
	
func on_move_made() -> void:
	movesMade += 1
	get_node('Moves').text = str(availableMoves - movesMade)
	if movesMade >= availableMoves:
		Events.on_moves_finished()

func on_level_started() -> void:
	prepare_Turn()
	
func prepare_Turn() -> void:
	for enemy in enemies:
		if enemy is Enemy:
			enemy.getNextMove()
