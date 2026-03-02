extends Node

const TOGGLE_DRONE = {
	"system": "SYSTEM_DND_TOGGLE",
	"manual": "SYSTEM_DND_TOGGLE_MANUAL",
	"price": 500000,
	"test_protocol": "drone",
	"warn_if_electric_below": 50,
	"slot_type": "HARDPOINT",
	"equipment_type": "EQUIPMENT_NANODRONES",
	"weapon_slot": {
		"path": "res://ToggleDrone/weapons/ToggleDrone.tscn",
		"data": [
			{
				"property": "visible",
				"value": "false"
			}
		]
	}
}

const TOGGLE_DRONE_HARVEST = {
	"system": "SYSTEM_DND_HARV_TOGGLE",
	"manual": "SYSTEM_DND_TOGGLE_MANUAL",
	"price": 555000,
	"test_protocol": "drone",
	"warn_if_electric_below": 120,
	"slot_type": "HARDPOINT",
	"equipment_type": "EQUIPMENT_NANODRONES",
	"mod_requirements": [["hev.IndustriesOfEnceladus"]],
	"weapon_slot": {
		"path": "res://ToggleDrone/weapons/ToggleDroneHarvest.tscn",
		"data": [
			{
				"property": "visible",
				"value": "false"
			}
		]
	}
}
