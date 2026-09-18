extends Control

var song_data: Dictionary
var song_http: HTTPRequest
var image_http: HTTPRequest
@onready var songTitleText = $SongTitle
@onready var songArtistText = $ArtistName
@onready var songArt = $MarginContainer/VBoxContainer/SongArt 

func _ready() -> void:
	# Initialize network nodes and attach them to the tree
	song_http = HTTPRequest.new()
	image_http = HTTPRequest.new()
	add_child(song_http)
	add_child(image_http)
	
	song_http.request_completed.connect(_on_song_request_completed)
	image_http.request_completed.connect(_on_cover_request_completed)

# Method 1: Populate if you already have the song data dictionary
func setup_by_dict(song: Dictionary) -> void:
	song_data = song
	songTitleText.text = song.get("title", "Unknown Title")
	songArtistText.text = song.get("artist", "Unknown Artist")
	
	var cover_art_id = song.get("coverArt", "")
	if cover_art_id != "":
		var cover_url = NavidromeInterface.ServerUrl + "/rest/getCoverArt.view?id=" + cover_art_id + "&u=" + NavidromeInterface.username + "&p=" + NavidromeInterface.password + "&v=1.16.1&c=Jurassify"
		image_http.request(cover_url)

# Method 2: Fetch data first if you only have a Song ID
func setup_by_id(song_id: String) -> void:
	# Uses the getSong.view endpoint
	var url = NavidromeInterface.ServerUrl + "/rest/getSong.view?id=" + song_id + "&u=" + NavidromeInterface.username + "&p=" + NavidromeInterface.password + "&v=1.16.1&c=Jurassify&f=json"
	song_http.request(url)

func _on_song_request_completed(result, response_code, headers, body):
	if response_code == 200:
		var json = JSON.parse_string(body.get_string_from_utf8())
		var response = json.get("subsonic-response", {})
		if response.has("song"):
			setup_by_dict(response["song"])

func _on_cover_request_completed(result, response_code, headers, body):
	if response_code == 200:
		var img = Image.new()
		# In Godot 4.3+, prefer img.load_from_buffer(body) for auto-detection
		if img.load_jpg_from_buffer(body) == OK:
			var texture = ImageTexture.create_from_image(img)
			
			# Note: Because your tree specifies SongArt is a Panel, 
			# you must apply a StyleBoxTexture rather than setting a .texture property.
			# (If you change SongArt to a TextureRect, use: songArt.texture = texture)
			var stylebox = StyleBoxTexture.new()
			stylebox.texture = texture
			songArt.add_theme_stylebox_override("panel", stylebox)


func _on_play_button_pressed() -> void:
	NavidromeInterface.setSelectedSong(song_data)
	get_tree().change_scene_to_file("res://fullscreen_player.tscn")
