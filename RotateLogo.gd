extends Panel

var tween: Tween

func _on_visibility_changed() -> void:
	if visible:
		# 1. Kill any existing tween to prevent duplicate animations
		if tween and tween.is_valid():
			tween.kill()
			
		# 2. Create a looping tween bound to this node
		tween = create_tween().bind_node(self).set_loops()
		
		# 3. Use rotation_degrees, relative movement, and linear transition
		tween.tween_property($Logo, "rotation_degrees", 360.0, 3.0).as_relative()
	else:
		# Stop the animation when hidden to save performance
		if tween and tween.is_valid():
			tween.kill()
