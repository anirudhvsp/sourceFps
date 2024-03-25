extends SubViewportContainer

# Called when the node enters the scene tree for the first time.
func _ready():
	# Get the window size
	var window_size = get_viewport_rect().size
	print(window_size)
	# Get the size of the HUD sprite (frame_size for AnimatedSprite2D)
	var hud_size = window_size/2
	print(hud_size)
	size = window_size
	# Set the initial position of the HUD sprite to the corner of the window
	#position.x = window_size.x - hud_size.x 
	#position.y = window_size.y - hud_size.y

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
