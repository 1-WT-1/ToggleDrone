extends Node

const TOGGLE_DRONE = {
	"system": "SYSTEM_DND_TOGGLE",
	"manual": "SYSTEM_DND_TOGGLE_MANUAL",
	"price": 500000,
	"test_protocol": "drone",
	"warn_if_electric_below": 50,
	"slot_type": "HARDPOINT",
	"equipment_type": "EQUIPMENT_NANODRONES"
}

const TOGGLE_DRONE_HARVEST = {
	"system": "SYSTEM_DND_HARV_TOGGLE",
	"manual": "SYSTEM_DND_TOGGLE_MANUAL",
	"price": 555000,
	"test_protocol": "drone",
	"warn_if_electric_below": 120,
	"slot_type": "HARDPOINT",
	"equipment_type": "EQUIPMENT_NANODRONES",
	"mod_requirements": [["hev.IndustriesOfEnceladus"]]
}
