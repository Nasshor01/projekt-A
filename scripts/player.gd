extends Area2D

signal game_over

var cooldown_timer = 1.0
var can_repel = true

func _ready():
	pass

func _unhandled_input(event):
	if event.is_action_pressed("repel") and can_repel:
		repel()

func _process(delta):
	if !can_repel:
		cooldown_timer -= delta
		if cooldown_timer <= 0:
			can_repel = true
			cooldown_timer = 1.0
		update_cooldown_visual()

func repel():
	can_repel = false
	var repel_range = 200
	var repel_strength = 500

	for enemy in get_tree().get_nodes_in_group("enemies"):
		var distance = global_position.distance_to(enemy.global_position)
		if distance < repel_range:
			var direction = (enemy.global_position - global_position).normalized()
			var impulse = direction * (repel_strength / (distance + 1)) # Add 1 to avoid division by zero
			enemy.repel(impulse)

func update_cooldown_visual():
	update() # Redraw the node

func _draw():
	if !can_repel:
		draw_circle(Vector2.ZERO, 30 * (1.0 - cooldown_timer), Color(1, 1, 1, 0.5))

func _on_Player_body_entered(body):
	if body.is_in_group("enemies"):
		emit_signal("game_over")
