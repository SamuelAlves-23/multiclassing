extends Area2D
class_name Hurtbox

@export var health_owner: Node  # Referencia al nodo que realmente tiene vida

func receive_hit(damage: int, knockback: Vector2):
	if health_owner and health_owner.has_method("apply_damage"):
		health_owner.apply_damage(damage)
