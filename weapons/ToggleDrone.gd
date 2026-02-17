extends "res://weapons/drone-plant.gd"

var _modes = ["haul", "tug"]
var _currentModeIndex = 0
var _haulStateInitialized = false
var _configLoaded = false
var _in_cycle = false
var _default_mode_applied = false

var _mode_display_node: Node2D
var _cached_hud_label = null
var _registration_attempted = false

export(String, "haul", "tug") var default_mode_override = ""

# Haul Mode Settings
export(float) var haul_minEnergyToTarget = 1.0
export(float) var haul_scanEvery = 2.0

# Tug Mode Settings
export(float) var tug_minEnergyToTarget = 300.0
export(float) var tug_scanEvery = 1.0


func _ready():
	if is_queued_for_deletion():
		return
	
	_haulStateInitialized = true
	_loadConfig()
	call_deferred("_initDefaultMode")

func _loadConfig():
	if _configLoaded:
		return
	_configLoaded = true
	
	var pointers = get_tree().get_root().get_node_or_null("HevLib~Pointers")
	if not pointers:
		Debug.l("[ToggleDrone] HevLib pointers not found!")
		return

	if pointers.ConfigDriver:
		var config = pointers.ConfigDriver.__get_config("ToggleDrone", "Mod_Configurations.cfg")
		var order = config.get("TDM_SETTINGS", {}).get("cycle_order", "TDM_ORDER_FIXED")
		if order == "TDM_ORDER_ADAPTIVE":
			var defaultIsHaul = ship.getTunedValue(slotName, "TUNE_DEFAULT_MODE", true) if ship else true
			if defaultIsHaul:
				_modes = ["haul", "tug"]
			else:
				_modes = ["tug", "haul"]
			#Debug.l("[ToggleDrone] Adaptive order: %s" % str(_modes))
		else:
			_modes = ["haul", "tug"]
			#Debug.l("[ToggleDrone] Fixed order: haul -> tug")

func _initDefaultMode():
	if not ship:
		return
	var defaultIsHaul = ship.getTunedValue(slotName, "TUNE_DEFAULT_MODE", true)
	var defaultMode = "haul" if defaultIsHaul else "tug"
	Debug.l("[ToggleDrone] _initDefaultMode: slot=%s, defaultIsHaul=%s, mode=%s" % [str(slotName), str(defaultIsHaul), defaultMode])

	#Check VP system toggles
	if _isVPDisabled():
		_currentModeIndex = _modes.size()
		_in_cycle = true
		enabled = false
		DronePickupArea.monitoring = false
		var parent = get_parent()
		if parent and "enabled" in parent:
			parent.enabled = false
		_in_cycle = false
		_default_mode_applied = true
		#Debug.l("[ToggleDrone] VP system toggle: disabled")
		_updateModeDisplay()
		return

	setDroneMode(defaultMode)
	_default_mode_applied = true

#Toggle Override 

func _isVPDisabled() -> bool:
	if not ship:
		return false
	var slot_name = get_parent().name if get_parent() else name
	var omsKey = "omstoggles.%s.%s" % [slot_name, systemName]
	var vp_state = ship.getConfig(omsKey, null)
	#Debug.l("[ToggleDrone] _isVPDisabled: key=%s val=%s" % [omsKey, str(vp_state)])
	if vp_state == null:
		return false
	return not vp_state

func _setEnabled(how: bool):
	if not ship:
		enabled = how
		return
	if _in_cycle:
		enabled = how
		return

	_in_cycle = true
	if how:
		var restore_index = _currentModeIndex if (_default_mode_applied and _currentModeIndex < _modes.size()) else 0
		_activateMode(restore_index)
		#Debug.l("[ToggleDrone] Enabled: %s" % _modes[restore_index])
	else:
		var nextIndex = _currentModeIndex + 1
		if nextIndex < _modes.size():
			_activateMode(nextIndex)
			#Debug.l("[ToggleDrone] Cycled to: %s" % _modes[nextIndex])
		else:
			_currentModeIndex = _modes.size()
			enabled = false
			DronePickupArea.monitoring = false
			ship.clearSystemTarget(self)
			#Debug.l("[ToggleDrone] Off")

	var parent = get_parent()
	if parent and "enabled" in parent:
		parent.enabled = enabled

	_in_cycle = false
	_updateModeDisplay()

func _activateMode(index: int):
	_currentModeIndex = index
	var mode = _modes[index]
	if mode == "haul":
		minEnergyToTarget = haul_minEnergyToTarget
		scanEvery = haul_scanEvery
	elif mode == "tug":
		minEnergyToTarget = tug_minEnergyToTarget
		scanEvery = tug_scanEvery
	
	droneFunction = mode
	enabled = true
	DronePickupArea.monitoring = true
	target = null
	scanProcess = scanEvery
	#Debug.l("[ToggleDrone] Activated mode: %s" % mode)

# Mode Helpers 

func setDroneMode(mode: String):
	#Debug.l("[ToggleDrone] setDroneMode(%s), _modes=%s" % [mode, str(_modes)])
	var index = _modes.find(mode)
	if index != -1:
		_activateMode(index)
	elif mode == "off":
		_currentModeIndex = _modes.size()
		enabled = false
		DronePickupArea.monitoring = false
		if ship:
			ship.clearSystemTarget(self)
	target = null
	scanProcess = scanEvery
	_in_cycle = true
	var parent = get_parent()
	if parent and "enabled" in parent:
		parent.enabled = enabled
	_in_cycle = false
	_updateModeDisplay()

func getCurrentModeName() -> String:
	if _currentModeIndex < _modes.size():
		return _modes[_currentModeIndex]
	return "off"

#Tuneables
#Display all tunings in all modes
func getTuneables():
	return {
		"TUNE_DEFAULT_MODE": {
			"type": "bool",
			"default": true,
			"current": ship.getTunedValue(slotName, "TUNE_DEFAULT_MODE", true) if ship else true,
			"testProtocol": "drone"
		},
		"TUNE_RANGE_MIN": {
			"type": "float",
			"min": 0,
			"max": maxDroneDistance / 10,
			"step": 10,
			"default": minDroneDistance / 10,
			"current": getRangeMin(),
			"unit": "m",
			"testProtocol": "drone"
		},
		"TUNE_RANGE_MAX": {
			"type": "float",
			"min": 0,
			"max": maxDroneDistance / 10,
			"step": 10,
			"default": maxDroneDistance / 10,
			"current": getRangeMax(),
			"unit": "m",
			"testProtocol": "drone"
		},
		"TUNE_RANGE_KEEP_AWAY": {
			"type": "float",
			"min": 0,
			"max": maxDroneDistance / 20,
			"step": 10,
			"default": haulMinDistance / 10,
			"current": getMinProximity(),
			"unit": "m",
			"testProtocol": "drone"
		},
		"TUNE_SLOW_ZONE": {
			"type": "float",
			"min": 10,
			"max": maxDroneDistance / 10,
			"step": 10,
			"default": haulDistance / 10,
			"current": getProximity(),
			"unit": "m",
			"testProtocol": "drone"
		}
	}

#HUD Display 

func _updateModeDisplay():
	if not ship:
		return
	var mode_name = getCurrentModeName().to_upper()
	var display_text = tr("SYSTEM_DND_TOGGLE_MODE_" + mode_name)

	if not _mode_display_node or not is_instance_valid(_mode_display_node):
		_mode_display_node = Node2D.new()
		_mode_display_node.name = "ToggleDroneMode_" + str(get_instance_id())
		_mode_display_node.set_script(preload("res://ToggleDrone/weapons/DroneDisplayNode.gd"))
		_mode_display_node.systemName = display_text
		add_child(_mode_display_node)
		call_deferred("_register_display_in_systemnodes")
	else:
		_mode_display_node.systemName = display_text

	call_deferred("_update_hud_label", _mode_display_node.name, display_text)

func _register_display_in_systemnodes():
	if _registration_attempted:
		return
	if not ship or not _mode_display_node or not is_instance_valid(_mode_display_node):
		return
	if not "systemNodes" in ship:
		return

	if ship.systemNodes.size() == 0:
		if ship.has_signal("systemPoll") and not ship.is_connected("systemPoll", self, "_on_system_poll"):
			ship.connect("systemPoll", self, "_on_system_poll", [], CONNECT_ONESHOT)
		return

	var my_slot = get_parent()
	var my_index = -1
	for i in range(ship.systemNodes.size()):
		var node = ship.systemNodes[i]
		if node == my_slot or node == self:
			my_index = i
			break
		elif "systemName" in node and node.systemName == "SYSTEM_DND_TOGGLE":
			if node.has_method("get_children"):
				for child in node.get_children():
					if child == self or (child.has_method("get_children") and self in child.get_children()):
						my_index = i
						break
			if my_index != -1:
				break

	if my_index != -1:
		if ship.systemNodes.find(_mode_display_node) == -1:
			ship.systemNodes.insert(my_index + 1, _mode_display_node)
	else:
		if ship.systemNodes.find(_mode_display_node) == -1:
			ship.systemNodes.append(_mode_display_node)
	_registration_attempted = true

func _on_system_poll():
	call_deferred("_register_display_in_systemnodes")

func _update_hud_label(node_id: String, new_text: String):
	if not ship or node_id.empty():
		return
	if _cached_hud_label and is_instance_valid(_cached_hud_label):
		_cached_hud_label.text = new_text.to_upper()
		return
	var hud = ship.get_node_or_null("Hud")
	if not hud:
		return
	var label = _find_hud_label(hud, node_id)
	if label:
		_cached_hud_label = label
		_cached_hud_label.text = new_text.to_upper()

func _find_hud_label(node, node_id: String):
	if "objects" in node and node.objects is Dictionary:
		if node.objects.has(node_id):
			var entry = node.objects[node_id]
			if "label" in entry and entry.label and is_instance_valid(entry.label):
				return entry.label
	for child in node.get_children():
		var result = _find_hud_label(child, node_id)
		if result:
			return result
	return null

#Cleanup 
func _exit_tree():
	if _mode_display_node and is_instance_valid(_mode_display_node):
		if ship and is_instance_valid(ship):
			if "systemNodes" in ship and _mode_display_node in ship.systemNodes:
				ship.systemNodes.erase(_mode_display_node)
			if "externalSystems" in ship and _mode_display_node in ship.externalSystems:
				ship.externalSystems.erase(_mode_display_node)
		_mode_display_node.queue_free()
	_mode_display_node = null
	_cached_hud_label = null
