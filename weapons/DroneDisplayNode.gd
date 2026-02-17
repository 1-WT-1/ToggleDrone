extends Node2D

var systemName = ""
var inspection = false

var enabled: bool setget , _get_enabled

func _get_enabled() -> bool:
	var parent = get_parent()
	if parent and "enabled" in parent:
		return parent.enabled
	return true

func getStatus():
	var parent = get_parent()
	if parent and parent.has_method("getStatus"):
		return parent.getStatus()
	return 100.0

func getPower():
	var parent = get_parent()
	if parent and parent.has_method("getPower"):
		return parent.getPower()
	return 1.0
