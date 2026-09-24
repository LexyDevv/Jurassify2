extends Control


func _on_line_edit_text_changed(new_text: String) -> void:
	NavidromeInterface.search_library(new_text)
