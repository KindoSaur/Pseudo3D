extends Node2D

@export var _map : Sprite2D          # Sprite2D with the Pseudo 3D Shader
@export var _minMapHeight : float    # minimal distance the map has to the viewpoint
@export var _maxMapHeight : float    # maximum distance the map has to the viewpoint

@export var _rotationSpeed : float   
@export var _horizontalMovementSpeed : float
@export var _verticalMovementSpeed : float
var _velocity : Vector3

@export var _fpsLabel : Label

func _process(delta):
	var mapRotationAngle : float = _map.material.get_shader_parameter("mapRotation")
	RotateMap(Input.get_action_strength("Rotate_Left") - Input.get_action_strength("Rotate_Right"), mapRotationAngle)
	
	var direction : Vector3 = Vector3(	Input.get_action_strength("Left") - Input.get_action_strength("Right"), 
										Input.get_action_strength("Ascend") - Input.get_action_strength("Descend"), 
										Input.get_action_strength("Forward") - Input.get_action_strength("Backward")
										)
	MoveMap(direction, mapRotationAngle)
	
	DisplayDebugText(	Engine.get_frames_per_second(), 
					_map.material.get_shader_parameter("mapPosition"), 
					_map.material.get_shader_parameter("mapRotation"), 
					rad_to_deg(_map.material.get_shader_parameter("mapRotation")))

func MoveMap(moveDir : Vector3, currMapAngle : float):
	if(moveDir == Vector3.ZERO): return
	
	moveDir = moveDir.normalized()
	
	var mapPosition : Vector3 = _map.material.get_shader_parameter("mapPosition")
	
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

func ReturnForward(mapAngle : float) -> Vector3:
	return Vector3(sin(mapAngle), 0, cos(mapAngle))

func ReturnRight(mapAngle : float) -> Vector3:
	return Vector3(cos(mapAngle), 0, -sin(mapAngle))

func RotateMap(rotDir : float, currMapAngle : float):
	if(rotDir == 0): return
	
	currMapAngle += rotDir * _rotationSpeed * get_process_delta_time()
	
	if(rad_to_deg(currMapAngle) > 360): currMapAngle -= deg_to_rad(360)
	elif (rad_to_deg(currMapAngle) < 0): currMapAngle += deg_to_rad(360)
	
	_map.material.set_shader_parameter("mapRotation", currMapAngle)

func DisplayDebugText(fps : float, mapPos : Vector3, mapRotRad : float, mapRotDeg : float):
	if(_fpsLabel == null): return
	var debugText : String
	debugText = "FPS: " + str(fps) + "\nMap Position: " + str(mapPos) + "\nMap Rotation Rad: " + str(mapRotRad) + "\nMap Rotation Deg: " + str(mapRotDeg)
	_fpsLabel.text = debugText
