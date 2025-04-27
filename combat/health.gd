extends Node
class_name Health

@export var max_health: int = 3
var current_health: int

@onready var heart01: Sprite2D = $Heart01
@onready var heart02: Sprite2D = $Heart02
@onready var heart03: Sprite2D = $Heart03

signal health_changed(current_health: int)
signal died()

func _ready():
	current_health = max_health

func apply_damage(amount: int):
	current_health -= amount
	draw_health()
	emit_signal("health_changed", current_health)
	if current_health <= 0:
		die()

func heal(amount: int):
	current_health = min(current_health + amount, max_health)
	draw_health()
	emit_signal("health_changed", current_health)

func die():
	emit_signal("died")
	# Podés agregar lógica específica de muerte aquí, o hacerla desde afuera

func draw_health():
	match current_health:
		3:
			heart01.frame = 0
			heart02.frame = 0
			heart03.frame = 0
		2:
			heart01.frame = 0
			heart02.frame = 0
			heart03.frame = 1
		1:
			heart01.frame = 0
			heart02.frame = 1
			heart03.frame = 1
		0:
			heart01.frame = 1
			heart02.frame = 1
			heart03.frame = 1
