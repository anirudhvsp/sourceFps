extends CharacterBody3D

# Movement
const MAX_VELOCITY_AIR = 0.8
const MAX_VELOCITY_GROUND = 8.0
const MAX_ACCELERATION = 10 * MAX_VELOCITY_GROUND
const GRAVITY = 20
const STOP_SPEED = 1.5
const JUMP_IMPULSE = sqrt(2 * GRAVITY * 0.85)
const PLAYER_WALKING_MULTIPLIER = 0.666
@onready var animated_sprite_2d = $Head/GunAnchor/Node2D/AnimatedSprite2D

@onready var omni_light_3d = $Head/OmniLight3D
var bullet_scene = preload("res://Scenes/bullet.tscn")  # Update the path to your bullet scene
var hitMarker = preload("res://Scenes/hit_marker.tscn")
@onready var ray_cast_3d = $Head/RayCast3D
@onready var head = $Head
@onready var gun_anchor = $Head/GunAnchor
var emissive_material : ShaderMaterial = preload("res://scripts/new_shader_material.tres")

var emissive_ray_duration = 1.0
var boost_force = 20.0  # Adjust the force of the boost
var boost_duration = 0.01  # Adjust the duration of the boost
var boostCooldownDuration = 0.2  # Adjust the cooldown duration for the boost
var boostCooldown = 0.0



var direction = Vector3()
var friction = 5
var wish_jump
var walking = false
var flash_duration = 0.15  # Adjust the duration of the flash as needed
var flash_timer = 0.0
var initial_light_energy = 15.0  # Initial energy value for the flash

# Camera
var sensitivity = 0.05

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
func _input(event):
	# Mouse lock
	if Input.is_action_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	elif Input.is_action_pressed("mouse_left"):
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	# Camera rotation
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		_handle_camera_rotation(event)
	
var head_rotation = Vector3()

func _handle_camera_rotation(event: InputEvent):
	# Rotate the camera based on the mouse movement
	rotate_y(deg_to_rad(-event.relative.x * sensitivity))
	$Head.rotate_x(deg_to_rad(-event.relative.y * sensitivity))
	
	# Store the normalized head rotation vector
	head_rotation = $Head.global_transform.basis.z.normalized()
	
	# Stop the head from rotating too far up or down
	$Head.rotation.x = clamp($Head.rotation.x, deg_to_rad(-60), deg_to_rad(90))
	
func _physics_process(delta):
	process_input()
	process_movement(delta)
	if flash_timer > 0.0:
		flash_timer -= delta
		if flash_timer <= 0.0:
			# Turn off the light when the flash is over
			omni_light_3d.light_energy = 0.0
		else:
			# Gradually reduce the light energy over the flash duration
			var t = 1.0 - flash_timer / flash_duration
			omni_light_3d.light_energy = lerp(initial_light_energy, 0.0, t)
	if boostCooldown > 0.0:
		boostCooldown -= delta
		if boostCooldown <= 0.0:
			boostCooldown = 0.0
	
func process_input():
	direction = Vector3()
	
	# Movement directions
	if Input.is_action_pressed("forward"):
		direction -= transform.basis.z
	elif Input.is_action_pressed("backward"):
		direction += transform.basis.z
	if Input.is_action_pressed("left"):
		direction -= transform.basis.x
	elif Input.is_action_pressed("right"):
		direction += transform.basis.x
		
	# Jumping
	wish_jump = Input.is_action_just_pressed("jump")
	
	# Walking
	walking = Input.is_action_pressed("walk")
	
	if Input.is_action_just_pressed("mouse_right") and boostCooldown == 0:
		var x = ray_cast_3d.get_collision_point()
		var hitMarkerInstance = hitMarker.instantiate()
		hitMarkerInstance.set_position(x)
		get_tree().root.add_child(hitMarkerInstance)
		var y = gun_anchor.get_global_position()
		apply_boost(x,y)
	
	if Input.is_action_just_pressed("mouse_left") and !animated_sprite_2d.is_playing():
		animated_sprite_2d.play("shoot")  
		flash_timer = flash_duration  # Start the flash timer
		omni_light_3d.light_energy = initial_light_energy
		'''var bullet_instance = bullet_scene.instantiate()
		var bullet_direction = direction.normalized()
		var player_transform = global_transform

		# Use the stored head rotation as the bullet direction
		# Set the bullet's initial rotation based on the head rotation
		var right_vector = head_rotation.cross(Vector3.UP).normalized()
		var up_vector = right_vector.cross(head_rotation).normalized()
		
		bullet_instance.global_transform = head.get_global_transform()  # Adjust the ssdistance as needed
		bullet_instance.set_position(1.05*head.global_position )
		bullet_instance.setShoot()
		get_tree().root.add_child(bullet_instance)'''
		var x = ray_cast_3d.get_collision_point()
		var hitMarkerInstance = hitMarker.instantiate()
		hitMarkerInstance.set_position(x)
		get_tree().root.add_child(hitMarkerInstance)
		var y = gun_anchor.get_global_position()
		create_emissive_ray(x,y)
		
		
		
func process_movement(delta):
	# Get the normalized input direction so that we don't move faster on diagonals
	var wish_dir = direction.normalized()

	if is_on_floor():
		# If wish_jump is true then we won't apply any friction and allow the 
		# player to jump instantly, this gives us a single frame where we can 
		# perfectly bunny hop
		if wish_jump:
			velocity.y = JUMP_IMPULSE
			# Update velocity as if we are in the air
			velocity = update_velocity_air(wish_dir, delta)
			wish_jump = false
		else:
			if walking:
				velocity.x *= PLAYER_WALKING_MULTIPLIER
				velocity.z *= PLAYER_WALKING_MULTIPLIER
			
			velocity = update_velocity_ground(wish_dir, delta)
	else:
		# Only apply gravity while in the air
		velocity.y -= GRAVITY * delta
		velocity = update_velocity_air(wish_dir, delta)

	# Move the player once velocity has been calculated
	move_and_slide()
	
func accelerate(wish_dir: Vector3, max_speed: float, delta):
	# Get our current speed as a projection of velocity onto the wish_dir
	var current_speed = velocity.dot(wish_dir)
	# How much we accelerate is the difference between the max speed and the current speed
	# clamped to be between 0 and MAX_ACCELERATION which is intended to stop you from going too fast
	var add_speed = clamp(max_speed - current_speed, 0, MAX_ACCELERATION * delta)
	
	return velocity + add_speed * wish_dir
	
func update_velocity_ground(wish_dir: Vector3, delta):
	# Apply friction when on the ground and then accelerate
	var speed = velocity.length()
	
	if speed != 0:
		var control = max(STOP_SPEED, speed)
		var drop = control * friction * delta
		
		# Scale the velocity based on friction
		velocity *= max(speed - drop, 0) / speed
	
	return accelerate(wish_dir, MAX_VELOCITY_GROUND, delta)
	
func update_velocity_air(wish_dir: Vector3, delta):
	# Do not apply any friction
	return accelerate(wish_dir, MAX_VELOCITY_AIR, delta)


func create_emissive_ray(start_point, end_point):
	# Create a new MeshInstance for the ray
	var emissive_ray = MeshInstance3D.new()
	var ray_mesh = CylinderMesh.new()  # You can adjust the mesh type as needed
	ray_mesh.bottom_radius = 0.01
	ray_mesh.top_radius = 0.01
	emissive_ray.material_override = emissive_material  # Apply the emissive material
	
	emissive_ray.mesh = ray_mesh
	# Set the position and scale of the ray
	emissive_ray.transform.origin = (start_point + end_point) / 2
	emissive_ray.transform.basis.y = (end_point - start_point).normalized()
	emissive_ray.transform.basis.x = Vector3(0, 1, 0).cross(emissive_ray.transform.basis.y).normalized()
	emissive_ray.transform.basis.z = emissive_ray.transform.basis.x.cross(emissive_ray.transform.basis.y).normalized()

	emissive_ray.scale.y = start_point.distance_to(end_point) / 2
	emissive_ray.scale.x = 0.1  # Adjust the thickness of the ray
	emissive_ray.scale.z = 0.1  # Adjust the thickness of the ray
	
	# Add the emissive ray to the scene
	get_tree().root.add_child(emissive_ray)

	# Reset the emissive ray duration
	emissive_ray_duration = 1.0


func apply_boost(x,y):
	# Get the direction vector between points X and Y
	var boost_direction = (y - x).normalized()

	# Apply the boost impulse to the player object
	velocity += boost_direction * boost_force

	# Start the boost cooldown
	boostCooldown = boostCooldownDuration
