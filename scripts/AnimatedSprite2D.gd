extends AnimatedSprite2D

# Called when the node enters the scene tree for the first time.
func _ready():
	# Get the window size
	var window_size = get_viewport_rect().size

	# Get the size of the HUD sprite (frame_size for AnimatedSprite2D)
	var hud_size = Vector2(260,260)

	# Set the initial position of the HUD sprite to the corner of the window
	position.x = window_size.x - hud_size.x / 2
	position.y = window_size.y - hud_size.y / 2

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
