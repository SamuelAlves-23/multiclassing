extends Node2D
class_name Hat

@onready var ability: Ability = $Ability
@onready var sprite: Sprite2D = $Sprite2D

@export var cooldown: float = 2.0
@export var icon: Texture2D
@export var ability_name: String = "Default Ability"
@export var player_owner: Player

var can_use_ability := true

func use_ability(_owner_node):
	if not can_use_ability:
		return

	can_use_ability = false
	sprite.modulate.a = 0.5
	print("Usando habilidad del sombrero: %s" % ability_name)
	
	ability.effect()
	
	# Esperar cooldown
	await get_tree().create_timer(cooldown).timeout
	sprite.modulate.a = 1
	can_use_ability = true
