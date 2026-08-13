extends Node2D

enum GameState{}
@onready var Bode: Character = $"SubViewportContainer/SubViewport/Enemy Units/Bode"
@onready var zarislov: Character = $"SubViewportContainer/SubViewport/Enemy Units/Zarislov"
@onready var elsbeth: Character = $"SubViewportContainer/SubViewport/Enemy Units/Elsbeth"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Bode.fortitude.setValue(22)
	Bode.body.setValue(13)
	Bode.dexterity.setValue(3)
	Bode.agility.setValue(2)
	Bode.mind.setValue(9)
	Bode.luck.setValue(1)
	
	Bode.bludgeons.setValue(10)
	Bode.armor.setValue(15)
	Bode.shields.setValue(10)
	Bode.grappling.setValue(10)
	
	zarislov.fortitude.setValue(17)
	zarislov.body.setValue(4)
	zarislov.dexterity.setValue(9)
	zarislov.agility.setValue(6)
	zarislov.mind.setValue(12)
	zarislov.luck.setValue(11)
	
	zarislov.medicine.setValue(15)
	zarislov.daggers.setValue(10)
	
	elsbeth.fortitude.setValue(11)
	elsbeth.body.setValue(3)
	elsbeth.dexterity.setValue(12)
	elsbeth.agility.setValue(11)
	elsbeth.mind.setValue(7)
	elsbeth.luck.setValue(6)
	
	elsbeth.bows.setValue(15)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
