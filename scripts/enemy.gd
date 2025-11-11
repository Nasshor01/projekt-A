extends RigidBody2D

var player_position = Vector2.ZERO
var speed = 50

func initialize(target_position):
	player_position = target_position

func _integrate_forces(state):
	var direction = (player_position - global_position).normalized()
	state.apply_central_force(direction * speed)

func repel(impulse):
	apply_central_impulse(impulse)

func _on_VisibilityNotifier2D_screen_exited():
	queue_free()
