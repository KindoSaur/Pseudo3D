extends Node2D

@export var _showDebugInfo : bool
@export var _debugLabel : Label

func _ready():
	_debugLabel.visible = _showDebugInfo

func ShowDebugInfo(mapText : Texture, mapPos : Vector3, mapRot : Vector2, playPos : Vector3, screenPos : Vector2):
	if(_debugLabel == null): 
		print("NO DEBUG_LABEL FOUND")
		_debugLabel.visible = false
		_showDebugInfo = false
		return 
	
	var debugText : String
	var fps : String = "FPS: " + str(Engine.get_frames_per_second())
	var mapPosition : String = "\nMap Position: " + str(mapPos * Vector3(mapText.get_width(),1, mapText.get_height()))
	var mapNormalizedPosition : String = "\nNormalized Map Position: " + str(mapPos)
	var mapRotationRadian : String = "\nMap Rotation Radians (YAW, PITCH) : " + str(mapRot)
	var mapRotationDegree : String = "\nMap Rotation Degrees (YAW, PITCH): " + str(Vector2(rad_to_deg(mapRot.x), rad_to_deg(mapRot.y)))
	var playerPosition : String = "\nPlayer Position " + str(playPos * Vector3(mapText.get_width(),1, mapText.get_height()))
	var playerNormalizedPosition : String = "\nNormalized Player Position " + str(playPos)
	var mouseScreenPosition : String = "\nMouse Screen Position " + str(get_global_mouse_position())
	var screenPosition : String = "\nGreen Pipe Screen Position: " + str(screenPos)
	
	debugText = fps + mapPosition + mapNormalizedPosition + mapRotationRadian + mapRotationDegree + playerPosition + playerNormalizedPosition + screenPosition + mouseScreenPosition 
	_debugLabel.text = debugText

func ReturnShowDebugInfo() -> bool: return _showDebugInfo
