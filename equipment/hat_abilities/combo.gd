extends Ability

@export var animator: AnimationPlayer

func effect():
	if animator:
		animator.play("Combo")
