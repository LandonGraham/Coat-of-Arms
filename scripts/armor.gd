extends invItem

class_name Armor

enum armorType{light, medium, heavy}
enum armorCategory{helmet, torso, legs, gauntlets}

@export var armor_type: armorType
@export var category: armorCategory
@export var skillRequirement: int
@export var durability: int
@export var currentDurability: int

@export var canBeTop: bool
@export var canBeBottom: bool

@export var pierceResistance: int
@export var slashResistance: int
@export var strikeResistance: int
@export var magicResistance: int
