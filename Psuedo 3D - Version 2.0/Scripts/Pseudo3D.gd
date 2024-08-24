extends Sprite2D

@export_category("Map Settings")
@export var _mapPosition : Vector3
@export var _minMaxMapHeight : Vector2
@export var _mapStartRotationAngle : float
@export var _mapRotationSpeed : float
@export var _mapVerticalMovementSpeed : float
@export var _mapHorizontalMovementSpeed : float
var _mapRotationAngle : float
var _finalMatrix : Basis

@export_category("Player Settings")
@export var _playerSprite : Sprite2D
@export var _playerMapMarkerRadius : float
@export var _playerMapMarkerColor : Color
@export var _playerMapPosition : Vector3

@export_category("Opponent Settings")
@export var _opponentMapMarkerRadius : float
@export var _opponentMapMarkerColor : Color
@export var _opponentMapPosition : Vector3
var _opponentScreenPosition : Vector2

@export_category("Debug Settings")
@export var _showDebugInfo : bool
@export var _debugLabel : Label

func _ready():
	_mapRotationAngle = _mapStartRotationAngle
	_debugLabel.visible = _showDebugInfo
	
	material.set_shader_parameter("opponentMarkerPosition", _opponentMapPosition)
	material.set_shader_parameter("opponentMarkerRadius", _opponentMapMarkerRadius)
	material.set_shader_parameter("opponentMarkerColor", _opponentMapMarkerColor)

func _process(delta):
	HandleInput()
	
	_playerSprite.position = WorldToScreenPosition(_opponentMapPosition)
	
	UpdateShader()
	if(_showDebugInfo):
		ShowDebugInfo()

func HandleInput():
	RotateMap(Input.get_action_strength("Rotate_Left") - Input.get_action_strength("Rotate_Right"))
	
	var direction : Vector3 = Vector3(	Input.get_action_strength("Left") - Input.get_action_strength("Right"), 
										Input.get_action_strength("Ascend") - Input.get_action_strength("Descend"), 
										Input.get_action_strength("Forward") - Input.get_action_strength("Backward")
										)
	
	MoveMap(direction)

func RotateMap(rotationDirection : int):
	if(rotationDirection == 0): return
	
	_mapRotationAngle += rotationDirection * _mapRotationSpeed * get_process_delta_time()
	
	if(rad_to_deg(_mapRotationAngle) > 360): _mapRotationAngle -= deg_to_rad(360)
	elif (rad_to_deg(_mapRotationAngle) < 0): _mapRotationAngle += deg_to_rad(360)

func MoveMap(dir : Vector3):
	if(dir == Vector3.ZERO): return
	
	dir = dir.normalized()
	var forward : Vector3 = Vector3(sin(_mapRotationAngle), 0, cos(_mapRotationAngle)) * dir.z
	var right : Vector3 = Vector3(cos(_mapRotationAngle), 0, -sin(_mapRotationAngle)) * dir.x
	var height : float = dir.y * _mapVerticalMovementSpeed
	
	var zoomLevel : float = _mapPosition.y;
	height *= (1.0 + zoomLevel)
	
	var velocity : Vector3 = (((forward + right) * _mapHorizontalMovementSpeed) + 
				   Vector3(0, height, 0)) * get_process_delta_time()
	
	_mapPosition += velocity
	_mapPosition.y = clamp(_mapPosition.y, _minMaxMapHeight.x, _minMaxMapHeight.y)

func UpdateShader():
	var yawMatrix : Basis = Basis(
		Vector3(-cos(_mapRotationAngle), sin(_mapRotationAngle), 0.0),
		Vector3(sin(_mapRotationAngle), cos(_mapRotationAngle), 0.0),
		Vector3(0.0,0.0,1.0)
	)
	
	var translationMatrix : Basis = Basis(
		Vector3(1.0, 0.0, 0.0),
		Vector3(0.0, 1.0, 0.0),
		Vector3(_mapPosition.x, _mapPosition.z, 1.0)
	)
	
	var heightMatrix : Basis = Basis(
		Vector3(1.0, 0.0, 0.0),
		Vector3(0.0, 0.0, exp(_mapPosition.y)),
		Vector3(0.0, 1.0, 0.0)
	)
	
	_finalMatrix = translationMatrix * yawMatrix * heightMatrix
	
	material.set_shader_parameter("mapMatrix", _finalMatrix)

func WorldToScreenPosition(world_pos : Vector3) -> Vector2:
	var transformed_pos = _finalMatrix.inverse() * Vector3(world_pos.x, world_pos.z, 1.0)
	if (transformed_pos.z < 0.0):
		return Vector2(-1000, -1000)  
	
	var screen_pos = Vector2(transformed_pos.x / transformed_pos.z, transformed_pos.y / transformed_pos.z) 
	screen_pos = (screen_pos + Vector2(0.5, 0.5)) * Vector2(480, 360)
	return screen_pos

func ShowDebugInfo():
	if(_debugLabel == null): 
		print("NO DEBUG_LABEL FOUND")
		_debugLabel.visible = false
		_showDebugInfo = false
		return 
	
	var debugText : String
	var fps : String = "FPS: " + str(Engine.get_frames_per_second())
	var mapPosition : String = "\nMap Position: " + str(_mapPosition * Vector3(texture.get_width(),1, texture.get_height()))
	var mapNormalizedPosition : String = "\nNormalized Map Position: " + str(_mapPosition)
	var mapRotationRadian : String = "\nMap Rotation Radians: " + str(_mapRotationAngle)
	var mapRotationDegree : String = "\nMap Rotation Degrees: " + str(rad_to_deg(_mapRotationAngle))
	var opponentPosition : String = "\nOpponent Position " + str(_opponentMapPosition * Vector3(texture.get_width(),1, texture.get_height()))
	var opponentNormalizedPosition : String = "\nNormalized Opponent Position " + str(_opponentMapPosition)
	var mouseScreenPosition : String = "\nMouse Screen Position " + str(get_global_mouse_position())
	
	var screenPosition : String = "\nScreen Position: " + str(WorldToScreenPosition(_opponentMapPosition))
	
	debugText = fps + mapPosition + mapNormalizedPosition + mapRotationRadian + mapRotationDegree + opponentPosition + opponentNormalizedPosition + screenPosition + mouseScreenPosition
	_debugLabel.text = debugText
