extends Control # Or whatever your container type is

@export var number_of_cards: int = 15 # Change this in the Godot Inspector

var big_song_card_scene = preload("res://Jurassify2/BigSongCard.tscn")
var small_song_card_scene = preload("res://Jurassify2/SmallSongCard.tscn")
var http_request_random_songs: HTTPRequest
var http_request_starred_songs: HTTPRequest

func _ready():
	http_request_random_songs = HTTPRequest.new()
	http_request_starred_songs = HTTPRequest.new()
	add_child(http_request_random_songs)
	add_child(http_request_starred_songs)
	http_request_random_songs.request_completed.connect(_on_random_songs_received)
	http_request_starred_songs.request_completed.connect(_on_starred_songs_received)
	var url = NavidromeInterface.ServerUrl + "/rest/getRandomSongs.view?size=" + str(number_of_cards) + "&u=" + NavidromeInterface.username + "&p=" + NavidromeInterface.password + "&v=1.16.1&c=Jurassify&f=json"
	var urlStarred = NavidromeInterface.ServerUrl + "/rest/getStarred.view?" + "&u=" + NavidromeInterface.username + "&p=" + NavidromeInterface.password + "&v=1.16.1&c=Jurassify&f=json"
	http_request_random_songs.request(url)
	http_request_starred_songs.request(urlStarred)

func _on_random_songs_received(result, response_code, headers, body):
	if response_code == 200:
		var json = JSON.parse_string(body.get_string_from_utf8())
		var response = json.get("subsonic-response", {})
		
		if response.has("randomSongs") and response["randomSongs"].has("song"):
			var songs_array = response["randomSongs"]["song"]
			for song_data in songs_array:
				var card = small_song_card_scene.instantiate()
				$MarginContainer/VBoxContainer/ScrollContainer2/SmallSongCardContainer.add_child(card)
				print(song_data)
				card.setup_by_dict(song_data)

func _on_starred_songs_received(result,response_code, headers, body):
	if response_code == 200:
		var json = JSON.parse_string(body.get_string_from_utf8())
		var response = json.get("subsonic-response",{})
		print("\n\n\nresponse:\n"+str(response))
		if response.has("starred") and response["starred"].has("song"):
			var songs_array = response["starred"]["song"]
			for song_data in songs_array:
				var card = big_song_card_scene.instantiate()
				$MarginContainer/VBoxContainer/ScrollContainer/BigSongCardContainer.add_child(card)
				card.setup_by_dict(song_data)
