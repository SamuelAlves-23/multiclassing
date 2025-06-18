extends Area2D
class_name Hitbox

@export var damage: int = 1
@export var knockback_force: Vector2 = Vector2.ZERO

@onready var collision: CollisionShape2D = $CollisionShape2D


func _ready():
	#$CollisionShape2D.disabled = true
	connect("area_entered", Callable(self, "_on_area_entered"))

func _on_area_entered(area):
	if area is Hurtbox:
		if "trapped" in area.get_parent():
			if area.get_parent().trapped and get_parent().name == "Arrow":
				area.receive_hit(3, knockback_force)
				return
			
		area.receive_hit(damage, knockback_force)
		#queue_free()
