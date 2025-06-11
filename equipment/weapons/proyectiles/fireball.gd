extends Node2D
class_name Fireball

@export var speed: float = 300.0
@export var direction: Vector2 = Vector2.RIGHT  # Esto se define al instanciar
@export var lifetime: float = 1.0

func _ready():
	# Auto-destrucción en X segundos
	await get_tree().create_timer(lifetime).timeout
	queue_free()

func _physics_process(delta):
	position += direction.normalized() * speed * delta
