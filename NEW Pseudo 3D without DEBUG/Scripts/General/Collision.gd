#Collision.gd
extends Node

@export var _collisionMap : Texture
var _textureImage : Image 
var _textureWidth : int = 1024
var _textureHeight : int = 1024

@export var _wallColor : Color
@export var _roadTypeColors : Array[Color]

func Setup():
	_textureImage = _collisionMap.get_image()
	_textureWidth = _textureImage.get_width()
	_textureHeight = _textureImage.get_height()

func AreColorsEqual(a : Color, b : Color, tolerance : float = 0):
	return abs(a.r8 - b.r8) <= tolerance and abs(a.g8 - b.g8) <= tolerance and abs(a.b8 - b.b8) <= tolerance and abs(a.a8 - b.a8) <= tolerance

func IsCollidingWithWall(position : Vector2i) -> bool: 
	if(position.x < 0 or position.y < 0 or position.x >= _textureWidth or position.y >= _textureHeight):
		return false
	
	var pixelColor : Color = _textureImage.get_pixel(position.x, position.y)
	return AreColorsEqual(pixelColor, _wallColor)

func ReturnCurrentRoadType(position : Vector2i) -> Globals.RoadType:
	var roadType : Globals.RoadType = Globals.RoadType.VOID
	var pixelColor : Color = _textureImage.get_pixel(position.x, position.y)
	
	for colorID in range(_roadTypeColors.size()):
		if(AreColorsEqual(pixelColor, _roadTypeColors[colorID])):
			roadType = colorID
	
	return roadType
