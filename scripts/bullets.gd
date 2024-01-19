extends Node3D

var nodes = []
var hitMarker = preload("res://Scenes/hit_marker.tscn")
# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func _process(delta):
	for i in nodes:
		var start = i.get_meta("start")
		var end = i.get_meta("end")
		if(i.global_position!= start):
			i.global_position = i.global_position.move_toward(start,0.5)
		else:
			i.queue_free()
			nodes.erase(i)
			var hitMarkerInstance = hitMarker.instantiate()
			hitMarkerInstance.set_position(i.get_meta("start"))
			hitMarkerInstance.set_meta("direction", start-end)
			get_tree().root.add_child(hitMarkerInstance)
			
		

func _on_child_entered_tree(node):
	if node.has_meta("start"):
		move_node_to_start_position(node)

func move_node_to_start_position(node):
	# Assuming you have a method or property to get the start position
	nodes.append(node)
	
