extends Node

class_name EventsListener

signal matchMade(type: String, value: int)
signal levelStarted()
signal moveMade()
signal movesFinished()
signal newTurn()
signal noMatchesFound()

func on_match_made(type: String, value: int) -> void:
	print("Scored " + str(value) + " of " + type)
	emit_signal("matchMade", type, value)
	
	
func on_level_started() -> void:
	print("Level started")
	emit_signal("levelStarted")
	
func on_move_made() -> void:
	print("Move made")
	emit_signal("moveMade")
	
func on_moves_finished() -> void:
	print("Moves finished")
	emit_signal("movesFinished")
	
func on_new_turn() -> void:
	print("New turn")
	emit_signal("newTurn")
	
func on_no_matches_found() -> void:
	print("No matches found")
	emit_signal("noMatchesFound")