extends Resource

class_name Techniques

@export var name: String = ""

enum damageType{pierce, slash, strike, magic}
enum statType{Fortitude, Body, Dexterity, Agility, Mind, Luck}
enum target{all, helmet, torso, legs, gauntlets}

@export var damage_type: damageType
@export var skillRequirement: int
@export var noOfHandsToUse: int 
@export var statToBeUsed: statType
@export var armorTarget: target
@export var attackRange: int
@export var minAttackRange: int

@export var damageMod: int
@export var toHitMod: int
@export var parryChanceMod: int
