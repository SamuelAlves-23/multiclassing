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
			
		area.receive_hit(get_parent().damage, knockback_force)
		#queue_free()


func _on_body_entered(body: Node2D) -> void:
	if get_parent() is Proyectile:
		get_parent().queue_free()
