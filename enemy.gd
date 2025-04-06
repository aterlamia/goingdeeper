extends Node2D
class_name Enemy

@onready var sprite: Sprite2D = get_node('Sprite')
@onready var attackLabel: Label = get_node("AttackLabel")
@onready var defenceLabel: Label = get_node("DefenceLabel")
@onready var healthBar: TextureProgressBar = get_node("HealthBar")
@onready var health: Label = get_node("HealthLabel")
@onready var swordIcon: Sprite2D = get_node("Attack")
@onready var shieldIcon: Sprite2D = get_node("Shield")
var healthValue: int  = 20
var attackValue: int  = 5
var defenceValue: int = 1
var maxHealth: int    = 20
var enemyType: String = "goblin"

var nextAction: String = "attack" # or "defend", "heal", etc.
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	setStats()
	animate_enemy_idle()
	pass # Replace with function body.


func set_enemy_type(type: String) -> void:
	enemyType = type
	# Set the enemy type here, e.g., change sprite or stats based on the type
	if enemyType == "goblin":
		sprite.texture = preload("res://Goblin.png")
	elif enemyType == "orc":
		sprite.texture = preload("res://Goblin.png")
	elif enemyType == "troll":
		sprite.texture = preload("res://Goblin.png")
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func setStats() -> void:
	attackLabel.text = str(attackValue)
	defenceLabel.text = str(defenceValue)
	healthBar.max_value = maxHealth
	healthBar.value = healthValue
	health.text = str(healthValue) + "/" + str(maxHealth)
	attackLabel.hide()
	swordIcon.hide()

	defenceLabel.hide()
	shieldIcon.hide()
	pass
		
	

func showAttack() -> void:
	defenceLabel.hide()
	shieldIcon.hide()
	attackLabel.show()
	swordIcon.show()
	pass

func showDefend() -> void:
	attackLabel.show()
	swordIcon.show()
	defenceLabel.hide()
	shieldIcon.hide()
	pass
func animate_enemy_idle() -> void:
	var tween = create_tween()
	tween.set_loops() # Makes the animation loop indefinitely

	# First squash (wider, shorter)
	tween.tween_property(sprite, "scale", Vector2(0.49, 0.49), 0.5)
	tween.tween_property(sprite, "scale", Vector2(0.5, 0.5), 0.25)

	# Then stretch (taller, thinner)
	tween.tween_property(sprite, "scale", Vector2(0.51, 0.51), 0.5)
	tween.tween_property(sprite, "scale", Vector2(0.5, 0.5), 0.25)
func getNextMove() -> void:	
	randomize()
	if(enemyType == "goblin"):
		# 50.50 chance to attack or defend
		var randomChance: int = randi() % 2
		if randomChance == 0:
			nextAction = "attack"
			showAttack()
		else:
			nextAction = "defend"
			showDefend()
	elif(enemyType == "orc"):
		# Orc logic
		print("Orc is defending!")
	elif(enemyType == "troll"):
		# Troll logic
		print("Troll is healing!")
	else:
		print("Unknown enemy type!")
		