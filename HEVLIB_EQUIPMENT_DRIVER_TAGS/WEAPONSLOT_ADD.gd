extends Node

const SYSTEM_DND_TOGGLE = {
	"name": "SYSTEM_DND_TOGGLE",
	"path": "res://ToggleDrone/weapons/ToggleDrone.tscn",
	"data": [
		{
			"property": "visible",
			"value": "false"
		}
	]
}

const SYSTEM_DND_HARV_TOGGLE = {
	"name": "SYSTEM_DND_HARV_TOGGLE",
	"path": "res://ToggleDrone/weapons/ToggleDroneHarvest.tscn",
	"data": [
		{
			"property": "visible",
			"value": "false"
		}
	],
	"mod_requirements": [["hev.IndustriesOfEnceladus"]]
}
