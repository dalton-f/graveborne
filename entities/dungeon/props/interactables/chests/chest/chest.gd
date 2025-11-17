extends Interactable

func _on_interacted(_body: Variant) -> void:
	print("chest opened")
	enabled = false
