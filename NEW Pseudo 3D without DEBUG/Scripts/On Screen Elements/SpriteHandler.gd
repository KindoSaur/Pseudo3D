#SpriteHandler.gd
extends Node2D

@export var _showSpriteInRangeOf : int = 440
@export var _hazards : Array[Hazard]
var _worldElements : Array[WorldElement]
var _player : Racer

var _mapSize : int = 1024
var _worldMatrix : Basis

func Setup(worldMatrix : Basis, mapSize : int, player : Racer):
	_worldMatrix = worldMatrix
	_mapSize = mapSize
	_player = player
	_worldElements.append(player)
	_worldElements.append_array(_hazards)
	WorldToScreenPosition(player)

func Update(worldMatrix : Basis):
	_worldMatrix = worldMatrix
	
	for hazard in _hazards:
		HandleSpriteDetail(hazard)
		WorldToScreenPosition(hazard)
	
	HandleYLayerSorting()

func HandleSpriteDetail(target : WorldElement):
	var playerPosition : Vector2 = Vector2(_player.ReturnMapPosition().x, _player.ReturnMapPosition().z)
	var targetPosition : Vector2 = Vector2(target.ReturnMapPosition().x, target.ReturnMapPosition().z)
	var distance : float = targetPosition.distance_to(playerPosition) * _mapSize
	
	target.ReturnSpriteGraphic().visible = true if distance < _showSpriteInRangeOf else false
	
	if(!target.ReturnSpriteGraphic().visible): return
	
	var detailStates : int = target.ReturnTotalDetailStates()
	var normalizedDistance : float = distance / _showSpriteInRangeOf
	var expFactor : float = pow(normalizedDistance, 0.75)
	var detailLevel : int = int(clamp(expFactor * detailStates, 0, detailStates - 1))
	var newRegionPos : int = target.ReturnSpriteGraphic().region_rect.size.y * detailLevel
	
	target.ReturnSpriteGraphic().region_rect.position.y = newRegionPos

func HandleYLayerSorting():
	_worldElements.sort_custom(SortByScreenY)
	for i in range(_worldElements.size()):
		var element = _worldElements[i]
		element.ReturnSpriteGraphic().z_index = i

func SortByScreenY(a : WorldElement, b : WorldElement) -> int:
	var aPosY : float = a.ReturnScreenPosition().y
	var bPosY : float = b.ReturnScreenPosition().y
	return aPosY < bPosY if -1 else (aPosY > bPosY if 1 else 0)

func WorldToScreenPosition(worldElement : WorldElement):
	var transformedPos : Vector3 = _worldMatrix.inverse() * Vector3(worldElement.ReturnMapPosition().x, worldElement.ReturnMapPosition().z, 1.0)
	if (transformedPos.z < 0.0):
		worldElement.SetScreenPosition(Vector2(-1000, -1000)) 
		return  
	
	var screenPos : Vector2 = Vector2(transformedPos.x / transformedPos.z, transformedPos.y / transformedPos.z) 
	screenPos = (screenPos + Vector2(0.5, 0.5)) * Globals.screenSize
	screenPos.y -= (worldElement.ReturnSpriteGraphic().region_rect.size.y * worldElement.ReturnSpriteGraphic().scale.x) / 2
	
	if(screenPos.floor().x > Globals.screenSize.x or screenPos.x < 0 or screenPos.floor().y > Globals.screenSize.y or screenPos.y < 0): 
		worldElement.visible = false
		worldElement.SetScreenPosition(Vector2(-1000, -1000)) 
		return  
	else:
		worldElement.SetScreenPosition(screenPos.floor())
