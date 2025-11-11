extends Node

enum GameState { READY, PLAYING, GAME_OVER }
var current_state = GameState.READY

var enemy_scene = preload("res://scenes/enemy.tscn")
var spawn_timer = 3.0
var time_since_last_spawn = 0.0

var score = 0.0
var high_score = 0.0

@onready var score_label = $ScoreLabel
@onready var high_score_label = $HighScoreLabel
@onready var message_label = $MessageLabel
@onready var player = $Player

func _ready():
	load_high_score()
	update_ui()
	player.game_over.connect(_on_Player_game_over)

func _on_Player_game_over():
	current_state = GameState.GAME_OVER
	if score > high_score:
		high_score = score
		save_high_score()
	update_ui()

func _process(delta):
	match current_state:
		GameState.READY:
			if Input.is_action_just_pressed("repel"):
				current_state = GameState.PLAYING
		GameState.PLAYING:
			score += delta
			time_since_last_spawn += delta
			if time_since_last_spawn >= spawn_timer:
				spawn_enemy()
				time_since_last_spawn = 0.0
				spawn_timer = max(0.5, spawn_timer * 0.99) # Increase spawn rate over time
			update_ui()
		GameState.GAME_OVER:
			if Input.is_action_just_pressed("repel"):
				get_tree().reload_current_scene()

func update_ui():
	score_label.text = "Score: %.1f" % score
	high_score_label.text = "Best: %.1f" % high_score

	match current_state:
		GameState.READY:
			message_label.text = "Press Space to Start"
		GameState.PLAYING:
			message_label.text = ""
		GameState.GAME_OVER:
			message_label.text = "GAME OVER\nPress Space to Restart"

func save_high_score():
	var file = FileAccess.open("user://highscore.dat", FileAccess.WRITE)
	file.store_float(high_score)

func load_high_score():
	if FileAccess.file_exists("user://highscore.dat"):
		var file = FileAccess.open("user://highscore.dat", FileAccess.READ)
		high_score = file.get_float()

func spawn_enemy():
	var new_enemy = enemy_scene.instantiate()
	var spawn_position = get_random_spawn_position()
	new_enemy.global_position = spawn_position
	new_enemy.initialize(player.global_position)
	new_enemy.add_to_group("enemies")
	add_child(new_enemy)

func get_random_spawn_position():
	var viewport_size = get_viewport().get_visible_rect().size
	var spawn_margin = 50
	var spawn_position = Vector2.ZERO

	match randi() % 4:
		0: # Top
			spawn_position.x = randf_range(-spawn_margin, viewport_size.x + spawn_margin)
			spawn_position.y = -spawn_margin
		1: # Bottom
			spawn_position.x = randf_range(-spawn_margin, viewport_size.x + spawn_margin)
			spawn_position.y = viewport_size.y + spawn_margin
		2: # Left
			spawn_position.x = -spawn_margin
			spawn_position.y = randf_range(-spawn_margin, viewport_size.y + spawn_margin)
		3: # Right
			spawn_position.x = viewport_size.x + spawn_margin
			spawn_position.y = randf_range(-spawn_margin, viewport_size.y + spawn_margin)

	return spawn_position
