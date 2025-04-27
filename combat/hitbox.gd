extends Area2D
class_name Hitbox

@export var damage: int = 1
@export var knockback_force: Vector2 = Vector2.ZERO

func _ready():
	connect("area_entered", Callable(self, "_on_area_entered"))

func _on_area_entered(area):
	if area is Hurtbox:
		area.receive_hit(damage, knockback_force)
		queue_free()
