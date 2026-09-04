extends Button
@onready var InputServerURL = $"../ServerURL"
@onready var InputUsername = $"../username"
@onready var InputPassword = $"../password"
@onready var Loading = $"../../Loading"
func _on_button_up() -> void:
	NavidromeInterface.setServerUrl(InputServerURL.text)
	NavidromeInterface.setUsername(InputUsername.text)
	NavidromeInterface.setPassword(InputPassword.text)
	NavidromeInterface.connectToServer()
