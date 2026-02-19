extends Node

const MOD_PRIORITY = 0
const MOD_NAME = "Toggle Drone"
const MOD_VERSION_MAJOR = 1
const MOD_VERSION_MINOR = 1
const MOD_VERSION_BUGFIX = 1
const MOD_VERSION_METADATA = ""
const MOD_IS_LIBRARY = false

var modPath: String = get_script().resource_path.get_base_dir() + "/"
var _savedObjects := []

func _init(modLoader = ModLoader):
	l("Initializing")
	l("Initialized")

func _ready():
	l("Readying")
	
	var pointers = preload("res://HevLib/pointers.gd").new()

	if pointers and pointers.ManifestV2:
		var mod_data = pointers.ManifestV2.__get_mod_data()
		if not mod_data.has("hev.IndustriesOfEnceladus"):
			replaceScene("weapons/ToggleDrone.tscn", "res://ToggleDrone/weapons/ToggleDroneHarvest.tscn")
	
	#replaceScene("weapons/ToggleDrone.tscn")
	l("Ready")

func replaceScene(newPath: String, oldPath: String = ""):
	l("Updating scene: %s" % newPath)

	if oldPath.empty():
		oldPath = str("res://" + newPath)

	newPath = str(modPath + newPath)

	var scene := load(newPath)
	if scene:
		scene.take_over_path(oldPath)
		_savedObjects.append(scene)
		l("Finished updating: %s" % oldPath)
	else:
		l("Failed to load scene: %s" % newPath)

func l(msg: String, title: String = MOD_NAME, version: String = str(MOD_VERSION_MAJOR) + "." + str(MOD_VERSION_MINOR) + "." + str(MOD_VERSION_BUGFIX)):
	if not MOD_VERSION_METADATA == "":
		version = version + "-" + MOD_VERSION_METADATA
	Debug.l("[%s V%s]: %s" % [title, version, msg])
