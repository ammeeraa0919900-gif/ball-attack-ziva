extends Area2D

var velocity = Vector2.ZERO

func _ready():
	add_to_group("balls")
	
	$Sprite2D.modulate = Color(randf(), randf(), randf())
	
	var s = randf_range(0.5, 1.5)
	scale = Vector2(s, s)

func _process(delta):
	position += velocity * delta

func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()

func _on_mouse_entered():
	get_parent().end_game()
