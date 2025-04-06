extends Node2D
class_name Player

signal attackDone

@onready var sprite: Sprite2D = get_node('Sprite')
@onready var attackLabel: Label = get_node("AttackLabel")
@onready var defenceLabel: Label = get_node("DefenceLabel")
@onready var healthBar: TextureProgressBar = get_node("HealthBar")
@onready var health: Label = get_node("HealthLabel")
@onready var swordIcon: Sprite2D = get_node("Attack")
@onready var shieldIcon: Sprite2D = get_node("Shield")
var healthValue: int  = 50
var attackValue: int  = 0
var defenceValue: int = 0
var maxHealth: int    = 50
var active_tweens = []

var events: EventsListener
# Called when the node enters the scene tree for the first time.
func _ready() -> void:

	setStats()
	console()
	Events.matchMade.connect(Callable(self, "on_match_made"))

	animate_player_idle()
	pass # Replace with function body.

func attack() -> void:	
	animate_player_action()

func on_match_made(type: String, value: int) -> void:
	# Handle the match made event
	if type == "health":
		heal(value)
	elif type == "sword":
		updateAttack(attackValue + value)
	elif type == "shield":
		updateDefence(defenceValue + value)
	elif type == "damage":
		hurt(value)
	elif type == "coin":
		# Handle coin collection here
		pass
	elif type == "neutral":
		# Handle neutral tile here
		pass

func animate_player_attack_done() -> void:
	animate_player_idle()
	attackDone.emit()
	
	
func animate_player_idle() -> void:
	active_tweens = active_tweens.filter(func(t): return t.is_valid())
	
	var tween: Tween = create_tween()
	tween.set_loops() # Makes the animation loop indefinitely
	active_tweens.append(tween)
	get_tree()
	# First squash (wider, shorter)
	tween.tween_property(sprite, "scale", Vector2(0.49, 0.49), 0.5)
	tween.tween_property(sprite, "scale", Vector2(0.5, 0.5), 0.25)

	# Then stretch (taller, thinner)
	tween.tween_property(sprite, "scale", Vector2(0.51, 0.51), 0.5)
	tween.tween_property(sprite, "scale", Vector2(0.5, 0.5), 0.25)


func animate_player_action() -> void:
	# Cancel any existing idle animation tween
	# Kill all existing tweens
	for tween in active_tweens:
		if tween.is_valid():
			tween.kill()
	active_tweens.clear()

	var tween: Tween = create_tween()
	active_tweens.append(tween)

	#move the player slightly to the right and back
	tween.tween_property(sprite, "position", sprite.position + Vector2(10, 0), 0.2)
	tween.tween_property(sprite, "position", sprite.position - Vector2(10, 0), 0.1)

	tween.tween_callback(animate_player_attack_done)
	
	
func console() -> void:
	# Print the current state of the player
	Console.add_hidden_command("sethealth", updateHealthConsole, ["health"], 1)
	Console.add_hidden_command("hurt", hurtConsole, ["damage"], 1)
	Console.add_hidden_command("heal", healConsole, ["health"], 1)
	Console.add_hidden_command("setmaxhealth", updateMaxHealthConsole, ["maxhealth"], 1)
	Console.add_hidden_command("setattack", updateAttackConsole, ["attack"], 1)
	Console.add_hidden_command("setdefence", updateDefenceConsole, ["defence"], 1)


func updateMaxHealthConsole(newMaxHealth: Variant) -> void:
	updateMaxHealth(int(newMaxHealth))
	pass


func updateAttackConsole(newAttack: Variant) -> void:
	updateAttack(int(newAttack))
	pass


func updateDefenceConsole(newDefence: Variant) -> void:
	updateDefence(int(newDefence))
	pass


func updateHealthConsole(newHealth: Variant) -> void:
	updateHealth(int(newHealth))
	pass

func hurtConsole(damage: Variant) -> void:
	hurt(int(damage))
	pass

func healConsole(healAmount: Variant) -> void:
	heal(int(healAmount))
	pass


func updateMaxHealth(newMaxHealth: int) -> void:
	maxHealth = newMaxHealth
	healthValue = min(newMaxHealth, healthValue)
	setStats()
	pass


func updateAttack(newAttack: int) -> void:
	attackValue = newAttack
	setStats()
	pass


func updateDefence(newDefence: int) -> void:
	defenceValue = newDefence
	setStats()
	pass


func updateHealth(newHealth: int) -> void:
	healthValue = newHealth
	setStats()
	pass


func hurt(damage: int) -> void:
	healthValue -= damage
	if (healthValue <= 0):
		healthValue = 0
	# Handle player death here
	setStats()
	pass


func heal(healAmount: int) -> void:
	healthValue += healAmount
	if (healthValue > maxHealth):
		healthValue = maxHealth
	setStats()
	pass


func setStats() -> void:
	# Initialize the player stats
	attackLabel.text = str(attackValue)
	defenceLabel.text = str(defenceValue)
	healthBar.max_value = maxHealth
	healthBar.value = healthValue
	health.text = str(healthValue) + "/" + str(maxHealth)
	if (attackValue > 0):
		attackLabel.show()
		swordIcon.show()
	else:
		attackLabel.hide()
		swordIcon.hide()

	if (defenceValue > 0):
		defenceLabel.show()
		shieldIcon.show()
	else:
		defenceLabel.hide()
		shieldIcon.hide()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
