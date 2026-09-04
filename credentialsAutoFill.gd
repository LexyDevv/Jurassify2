extends Control
@onready var urlLineEdit = $VBoxContainer/ServerURL
@onready var usernameLineEdit = $VBoxContainer/username
@onready var passwordLineEdit = $VBoxContainer/password
func _ready() -> void:
	var cred:Dictionary = NavidromeInterface.readCredentialsEncrypted()
	if cred.is_empty():
		print("no saved credentials found")
		return
	urlLineEdit.text = cred.get("serverUrl","")
	usernameLineEdit.text = cred.get("username","")
	passwordLineEdit.text = cred.get("password","")
