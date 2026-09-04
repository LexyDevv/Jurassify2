#this script makes it possible to call the context menu so the user can hold a tap to see options
#like "select all" and "paste" on a smartphone
extends LineEdit

var hold_timer: Timer

func _ready():
	# Set up a timer to detect long presses
	hold_timer = Timer.new()
	hold_timer.wait_time = 0.5 # Seconds required to trigger the menu
	hold_timer.one_shot = true
	hold_timer.timeout.connect(_show_context_menu)
	add_child(hold_timer)

func _gui_input(event):
	# Listen for mobile screen touch (or mouse click for testing)
	if event is InputEventScreenTouch or event is InputEventMouseButton:
		if event.pressed:
			hold_timer.start()
		else:
			hold_timer.stop() # Cancels the timer if the user releases early

func _show_context_menu():
	# get_menu() returns the native Godot PopupMenu pre-wired with Copy/Paste logic
	var menu = get_menu()
	
	# Get the current touch position and convert to Vector2i for the Window API
	var tap_pos = Vector2i(get_global_mouse_position())
	
	# Display the popup exactly at the tap location
	menu.popup(Rect2i(tap_pos, Vector2i()))
