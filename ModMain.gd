extends Node

const MOD_PRIORITY = 0
const MOD_NAME = "Toggle Drone"
const MOD_VERSION_MAJOR = 1
const MOD_VERSION_MINOR = 1
const MOD_VERSION_BUGFIX = 3
const MOD_VERSION_METADATA = ""

var modPath: String = get_script().resource_path.get_base_dir() + "/"
var _savedObjects := []

func _init(modLoader = ModLoader):
	l("Initializing")
	l("Initialized")

func l(msg: String, title: String = MOD_NAME, version: String = str(MOD_VERSION_MAJOR) + "." + str(MOD_VERSION_MINOR) + "." + str(MOD_VERSION_BUGFIX)):
	if not MOD_VERSION_METADATA == "":
		version = version + "-" + MOD_VERSION_METADATA
	Debug.l("[%s V%s]: %s" % [title, version, msg])
