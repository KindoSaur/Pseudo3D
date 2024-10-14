#Globals.gd
extends Node

var screenSize : Vector2 = Vector2(480, 360)

enum RoadType {
	VOID = 0,
	ROAD = 1,
	GRAVEL = 2,
	OFF_ROAD = 3,
	WALL = 4,
	SINK = 5
} 
