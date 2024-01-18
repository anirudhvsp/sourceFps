extends Node3D
@onready var gpu_particles_3d = $GPUParticles3D

func _ready():
	gpu_particles_3d.restart()
	
func _process(delta):
	var time_in_seconds = 1
	await get_tree().create_timer(time_in_seconds).timeout
	queue_free()
	
	
