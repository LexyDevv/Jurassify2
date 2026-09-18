extends Node
var ServerUrl
var username
var password
var http_request: HTTPRequest
var audio_player: AudioStreamPlayer
var audio_http: HTTPRequest
var active_loading_screen: Node = null
var validCredentials = false
var selectedSong: Dictionary
var token
var salt
signal random_songs_received(songs_array: Array)


func _ready():
	http_request = HTTPRequest.new()
	add_child(http_request)
	http_request.request_completed.connect(_on_request_completed)
	http_request.timeout = 10.0
	# Setup global audio player
	audio_player = AudioStreamPlayer.new()
	add_child(audio_player)
	
	# Setup dedicated HTTP request for audio
	audio_http = HTTPRequest.new()
	add_child(audio_http)
	audio_http.request_completed.connect(_on_audio_downloaded)

func setServerUrl(URL:String):
	ServerUrl=URL
	print("URL changed")
	validCredentials=false

func setUsername(user:String):
	username=user
	print("Username changed")
	validCredentials=false

func setPassword(pwd:String):
	password=pwd
	print("Password changed")
	validCredentials=false

func connectToServer():
	salt = str(randi()) # Simple random salt
	token = (password + salt).md5_text()
	
	var request_url = ServerUrl + "/rest/ping.view?u=" + username + "&t=" + token + "&s="+ salt + "&v=1.16.1&c=Jurassify&f=json"
	http_request.request(request_url)
	
	loading()
	await http_request.request_completed
	stopLoading()
	if validCredentials==true:
		saveCredentials(ServerUrl,username,token,salt)
		get_tree().change_scene_to_file("res://Jurassify2/Home.tscn")
	

func _on_request_completed(result, response_code, headers, body):
	if response_code == 200:
		var json = JSON.parse_string(body.get_string_from_utf8())
		if json and json.has("subsonic-response"):
			var status = json["subsonic-response"]["status"]
			if status == "ok":
				print("You got in!")
				validCredentials=true
			else:
				print("Connection attempt failed: ", json["subsonic-response"]["error"]["message"])
	else:
		print("Network or server error")

func loading():
	if active_loading_screen == null:
		active_loading_screen = preload("res://Jurassify2/loading.tscn").instantiate()
		active_loading_screen.z_index = 1
		get_tree().current_scene.add_child(active_loading_screen)

func stopLoading():
	if active_loading_screen != null:
		active_loading_screen.queue_free()
		active_loading_screen = null

func saveCredentials(url: String, user: String, token: String, salt: String) -> void:
	var file = FileAccess.open_encrypted_with_pass("user://auth.dat", FileAccess.WRITE, "8d16KiNd")
	var data = {
		"serverUrl": url,
		"username": user,
		"password": password, #it's fine to store the password since the file is already encrypted
	}
	file.store_string(JSON.stringify(data))

func readCredentialsEncrypted() -> Dictionary:
	if not FileAccess.file_exists("user://F.dat"):
		return {}
		
	var file = FileAccess.open_encrypted_with_pass("user://auth.dat", FileAccess.READ, "8d16KiNd")
	if file == null:
		print("Failed to decrypt or open file")
		return {}
	
	var parsed = JSON.parse_string(file.get_as_text())
	return parsed if parsed is Dictionary else {}

func setSelectedSong(song: Dictionary):
	selectedSong=song
	
func getSelectedSong() -> Dictionary:
	return selectedSong


func playSongAudio(song: Dictionary) -> void:
	# Use the modular auth string you built earlier
	var request_url = ServerUrl + "/rest/download?id=" + song.get("id", "") + "&u=" + username + "&t=" + token + "&s="+ salt + "&v=1.16.1&c=Jurassify&f=json"
	print("Downloading audio for: ", song.get("title", "Unknown"))
	loading()
	audio_http.request(request_url)

func _on_audio_downloaded(result, response_code, headers, body):
	stopLoading()
	if response_code == 200:
		var stream = AudioStreamMP3.new()
		stream.data = body
		audio_player.stream = stream
		audio_player.play()
	else:
		print("Failed to download audio. Code: ", response_code)
