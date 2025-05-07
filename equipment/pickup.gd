extends Area2D
class_name Pickup

@onready var sprite: Sprite2D = $Sprite2D

@export var item_scene: PackedScene
@export var type: String

var item

func _ready():
	if item_scene:
		item = item_scene.instantiate()

		if "sprite" in item:
			sprite.texture = item.sprite


func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		#var item = item_scene.instantiate()
		if type == "weapon":
			body.equip_weapon(item)
		elif type == "hat":
			body.equip_hat(item)

		queue_free()
