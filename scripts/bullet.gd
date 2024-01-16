extends RigidBody3D

@onready var mesh_instance_3d = $MeshInstance3D
@onready var omni_light_3d = $OmniLight3D
@onready var collision_shape_3d = $Area3D/CollisionShape3D
@onready var area_3d = $Area3D

var shot = false
var acceleration = 15.0  # Adjust the acceleration as needed

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if shot:
		# Accelerate the bullet in its facing direction
		var impulse = -global_transform.basis.z.normalized() * acceleration
		apply_impulse(impulse)
		shot = false
		# Optionally, you may want to disable the light and collision after some time or when the bullet is out of bounds
		# You can add a timer or check if the bullet is out of the camera view and queue_free() it.

func setShoot():
	shot = true
