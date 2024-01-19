extends Node3D

@onready var gpu_particles_3d = $GPUParticles3D

func _ready():
	gpu_particles_3d.restart()
	var direction = get_meta("direction").normalized()
	
	var cylinder_mesh = CylinderMesh.new()
	var cylinder_instance = MeshInstance3D.new()
	cylinder_instance.mesh = cylinder_mesh
	cylinder_mesh.top_radius = 0.05  # Set your desired radius
	cylinder_mesh.bottom_radius = 0.05  # Set your desired radius
	cylinder_mesh.height = direction.length()  # Set height based on direction length
	
	# Align the cylinder with the direction vector
	var rotation = Basis().looking_at(direction, Vector3.UP).orthonormalized()
	cylinder_instance.transform.basis = rotation
	
	# Move the cylinder to the starting point
	var start_point = cylinder_instance.to_local(Vector3.ZERO)
	cylinder_instance.transform.origin = start_point
	gpu_particles_3d.process_material.direction = direction

func _process(delta):
	var time_in_seconds = 1
	await get_tree().create_timer(time_in_seconds).timeout
	queue_free()
