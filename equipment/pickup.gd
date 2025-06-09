extends Area2D
class_name Pickup

@onready var sprite: Sprite2D = $Sprite2D
@onready var pickable: bool = false

@export var item_scene: PackedScene
@export var path: String
@export var spawn_time: float = 1
var item

func _ready():
	if item_scene:
		item = item_scene.instantiate()
		path = item.scene_file_path
		if item.has_node("Sprite2D"):
			var item_sprite = item.get_node("Sprite2D") as Sprite2D
			sprite.texture = item_sprite.texture
	await get_tree().create_timer(spawn_time).timeout
	pickable = true

func _on_body_entered(body: Node2D) -> void:
	if body is Player and pickable:
		#var item = item_scene.instantiate()
		if "weapons" in path:
			body.equip_weapon(item)
		elif "hats" in path:
			body.equip_hat(item)

		queue_free()
