extends CharacterBody2D
class_name Doomy

@onready var health: Health = $Health
@onready var hurtbox: Hurtbox = $Hurtbox

func _ready() -> void:
	health.connect("died", die)




func die():
	queue_free()
