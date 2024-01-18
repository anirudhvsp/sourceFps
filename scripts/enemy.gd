extends Node3D
var health : int = 100

@onready var body = $hitbox/body
@onready var head = $hitbox/head
var hitMarker = preload("res://Scenes/hit_marker.tscn")
func _ready():
	pass

	
func _on_hit(body_part):
	match body_part:
		"Head":
			take_damage(100)
		"Body":
			take_damage(25)

func take_damage(damage):
	health -= damage
	if health <= 0:
		die()

func die():
	# Handle enemy death logic here
	queue_free()

func _on_body_body_entered(body):
	if(body.scene_file_path == "res://Scenes/hit_marker.tscn"):
		_on_hit("Body")
func _on_head_body_entered(body):
	if(body.scene_file_path == "res://Scenes/hit_marker.tscn"):
		_on_hit("Head")
