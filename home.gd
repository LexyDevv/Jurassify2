extends Control # Or whatever your container type is

@export var number_of_cards: int = 15 # Change this in the Godot Inspector

var song_card_scene = preload("res://Jurassify2/BigSongCard.tscn")
var http_request: HTTPRequest

func _ready():
	http_request = HTTPRequest.new()
	add_child(http_request)
	http_request.request_completed.connect(_on_random_songs_received)
	var url = NavidromeInterface.ServerUrl + "/rest/getRandomSongs.view?size=" + str(number_of_cards) + "&u=" + NavidromeInterface.username + "&p=" + NavidromeInterface.password + "&v=1.16.1&c=Jurassify&f=json"
	http_request.request(url)

func _on_random_songs_received(result, response_code, headers, body):
	if response_code == 200:
		var json = JSON.parse_string(body.get_string_from_utf8())
		var response = json.get("subsonic-response", {})
		if response.has("randomSongs") and response["randomSongs"].has("song"):
			var songs_array = response["randomSongs"]["song"]
			for song_data in songs_array:
				var card = song_card_scene.instantiate()
				$MarginContainer/VBoxContainer/ScrollContainer/BigSongCardContainer.add_child(card)
				card.setup_by_dict(song_data)
