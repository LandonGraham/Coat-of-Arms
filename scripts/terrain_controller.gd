extends Node2D

class_name TerrainController

# Dictionary:
# Key   = tile global position
# Value = MapTile node
var terrain_tiles : Dictionary = {}

func _ready():
	buildTerrainDictionary()


func buildTerrainDictionary():
	terrain_tiles.clear()

	for child in get_children():
		if child is MapTile:
			terrain_tiles[child.global_position] = child


func getTerrainTile(tile_position : Vector2) -> MapTile:
	if terrain_tiles.has(tile_position):
		return terrain_tiles[tile_position]

	return null


func getMovementCost(tile_position : Vector2) -> int:
	var tile = getTerrainTile(tile_position)

	if tile == null:
		return 1

	return tile.movementReq


func blocksMovement(tile_position : Vector2) -> bool:
	var tile = getTerrainTile(tile_position)

	if tile == null:
		return false

	return tile.blocksMovement
