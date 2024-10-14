#BackgroundEffects.gd
extends Node2D

@export var _skyLine : Sprite2D
@export var _treeLine : Sprite2D

func Setup():
	pass

func Update(mapRotation : float):
	MoveBackgroundElements(_skyLine, mapRotation)
	MoveBackgroundElements(_treeLine, mapRotation)

func MoveBackgroundElements(element : Sprite2D, mapRotation : float):
	var rotationDegree : float = rad_to_deg(mapRotation) / 360
	var scrollPosition : float = rotationDegree * element.texture.get_width()
	element.region_rect.position.x = -scrollPosition

