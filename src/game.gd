extends Node

@onready var score_label = $CanvasLayer/score_label
@onready var game_over_popup = $CanvasLayer/gameover_popup
@onready var spawn_timer = $ball_spawn_timer
@onready var score_timer = $score_timer

var score = 0
var game_over = false
var screen_size
var base_speed
var base_spawn_rate = 2.0
var difficulty_mult = 1.0

func _ready():
	start_game()
	spawn_timer.timeout.connect(spawn_ball)
	score_timer.timeout.connect(increment_score)
	screen_size = get_viewport().get_visible_rect().size
	base_speed = screen_size.length() / 10.0
	randomize()

func _process(delta):
	$background.modulate.h += 0.02 * delta * difficulty_mult

func _input(event):
	if game_over:
		if event is InputEventMouseButton and event.pressed:
			restart_game()

func start_game():
	game_over = false
	score = 0
	difficulty_mult = 1.0
	score_label.text = "Score: 0"
	game_over_popup.hide()
	spawn_timer.wait_time = 1.0 / base_spawn_rate
	spawn_timer.start()
	score_timer.start()
	get_tree().call_group("balls", "queue_free")

func spawn_ball():
	if game_over:
		return
	var ball_scene = preload("res://scenes/ball_entity.tscn")
	var ball = ball_scene.instantiate()
	add_child(ball)
	var side = randi() % 4
	var pos = Vector2()
	if side == 0:
		pos.x = randf_range(0, screen_size.x)
		pos.y = -50
	elif side == 1:
		pos.x = screen_size.x + 50
		pos.y = randf_range(0, screen_size.y)
	elif side == 2:
		pos.x = randf_range(0, screen_size.x)
		pos.y = screen_size.y + 50
	else:
		pos.x = -50
		pos.y = randf_range(0, screen_size.y)
	ball.position = pos
	var target = screen_size / 2
	target.x += randf_range(-screen_size.x * 0.3, screen_size.x * 0.3)
	target.y += randf_range(-screen_size.y * 0.3, screen_size.y * 0.3)
	ball.velocity = (target - ball.position).normalized() * (base_speed * difficulty_mult)

func increment_score():
	if game_over:
		return
	score += 1
	score_label.text = "Score: %s" % score
	difficulty_mult += 0.02
	spawn_timer.wait_time = 1.0 / (base_spawn_rate * (difficulty_mult * 0.5 + 0.5))

func end_game():
	if game_over:
		return
	game_over = true
	spawn_timer.stop()
	score_timer.stop()
	game_over_popup.show()

func restart_game():
	get_tree().reload_current_scene()
