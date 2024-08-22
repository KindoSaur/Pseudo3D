extends Node2D

@export_subgroup("Map Settings")
@export var _map : Sprite2D          # Sprite2D with the Pseudo 3D Shader
@export var _minMapHeight : float    # minimal distance the map has to the viewpoint
@export var _maxMapHeight : float    # maximum distance the map has to the viewpoint

@export_subgroup("Movement Settings")
@export var _rotationSpeed : float
@export var _rotationRadius : float
@export var _horizontalMovementSpeed : float
@export var _verticalMovementSpeed : float

var _velocity : Vector3
var _currMapAngle : float

@export_category("Debug Settings")
@export var _debugInfoLabel : Label

func _ready():
	_map.material.set_shader_parameter("markerPosition", ReturnNewMarkerPosition(	ReturnMapPosition(), 
																					ReturnMapRotation()))

func _process(delta):
	_currMapAngle = ReturnMapRotation()
	RotateMap(Input.get_action_strength("Rotate_Left") - Input.get_action_strength("Rotate_Right"))
	
	var direction : Vector3 = Vector3(	Input.get_action_strength("Left") - Input.get_action_strength("Right"), 
										Input.get_action_strength("Ascend") - Input.get_action_strength("Descend"), 
										Input.get_action_strength("Forward") - Input.get_action_strength("Backward")
										)
	MoveMap(direction, _currMapAngle)
	
	DisplayDebugText(	Engine.get_frames_per_second(), 
					ReturnMapPosition(), 
					ReturnMapRotation(), 
					rad_to_deg(ReturnMapRotation()))

func MoveMap(moveDir : Vector3, currMapAngle : float):
	if(moveDir == Vector3.ZERO): return
	
	moveDir = moveDir.normalized()
	
	var mapPosition : Vector3 = ReturnMapPosition()
	
	var forwardMovement = ReturnForward(currMapAngle) * moveDir.z 
	var rightMovement = ReturnRight(currMapAngle) * moveDir.x
	var heightMovement : float = moveDir.y * _verticalMovementSpeed
	
	var zoomLevel : float = mapPosition.y;
	heightMovement *= (1.0 + zoomLevel)
	
	_velocity = (((forwardMovement + rightMovement) * _horizontalMovementSpeed) + 
				   Vector3(0, heightMovement, 0)) * get_process_delta_time()
	
	mapPosition += _velocity
	mapPosition.y = clamp(mapPosition.y, _minMapHeight, _maxMapHeight)
	_map.material.set_shader_parameter("mapPosition", mapPosition)
	_map.material.set_shader_parameter("markerPosition", ReturnNewMarkerPosition(mapPosition, _currMapAngle))

func RotateMap(rotDir : float):
	if(rotDir == 0): return
	
	_currMapAngle += rotDir * _rotationSpeed * get_process_delta_time()
	
	if(rad_to_deg(_currMapAngle) > 360): _currMapAngle -= deg_to_rad(360)
	elif (rad_to_deg(_currMapAngle) < 0): _currMapAngle += deg_to_rad(360)
	
	_map.material.set_shader_parameter("mapRotation", _currMapAngle)
	
	var moveDir : Vector3 = Vector3(-rotDir * _rotationRadius,0,0)
	var mapPosition : Vector3 = ReturnMapPosition()
	var rightMovement = ReturnRight(_currMapAngle) * moveDir.x
	
	_velocity = rightMovement * _rotationSpeed * get_process_delta_time()
	
	mapPosition += _velocity
	_map.material.set_shader_parameter("mapPosition", mapPosition)
	_map.material.set_shader_parameter("markerPosition", ReturnNewMarkerPosition(mapPosition, _currMapAngle))

func ReturnForward(mapAngle : float) -> Vector3:
	return Vector3(sin(mapAngle), 0, cos(mapAngle))

func ReturnRight(mapAngle : float) -> Vector3:
	return Vector3(cos(mapAngle), 0, -sin(mapAngle))

func ReturnMapRotation() -> float:
	return _map.material.get_shader_parameter("mapRotation")

func ReturnMapPosition() -> Vector3:
	return _map.material.get_shader_parameter("mapPosition")

func DisplayDebugText(fps : float, mapPos : Vector3, mapRotRad : float, mapRotDeg : float):
	if(_debugInfoLabel == null): return
	var debugText : String
	debugText = "FPS: " + str(fps) + "\nMap Position: " + str(mapPos) + "\nMap Rotation Rad: " + str(mapRotRad) + "\nMap Rotation Deg: " + str(mapRotDeg) + "\nMarker Position " + str(_map.material.get_shader_parameter("markerPosition"))
	_debugInfoLabel.text = debugText

func ReturnNewMarkerPosition(mapPosition : Vector3, mapAngle : float) -> Vector3:
	return Vector3(mapPosition.x, 0, mapPosition.z) + (ReturnForward(mapAngle).normalized() * _rotationRadius)
