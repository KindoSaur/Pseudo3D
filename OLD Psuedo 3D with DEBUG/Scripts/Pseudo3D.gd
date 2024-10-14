extends Sprite2D

@export_category("Map Settings")
@export var _mapPosition : Vector3
@export var _minMaxMapHeight : Vector2
@export var _mapStartRotationAngle : Vector2
@export var _mapRotationSpeed : float
@export var _rotationRadius : float
@export var _mapVerticalMovementSpeed : float
@export var _mapHorizontalMovementSpeed : float
var _velocity : Vector3
var _mapRotationAngle : Vector2
var _finalMatrix : Basis

@export_category("Player Settings")
@export var _playerSprite : Sprite2D
@export var _playerMapMarkerRadius : float
@export var _playerMapMarkerColor : Color
@export var _playerMapPosition : Vector3

@export_category("Opponent Settings")
@export var _opponentSprite : Sprite2D
@export var _opponentMapMarkerRadius : float
@export var _opponentMapMarkerColor : Color
@export var _opponentMapPosition : Vector3
var _opponentScreenPosition : Vector2

@export_category("Debug Settings")
@export var _debugContainer : Node2D

func _ready():
	_mapRotationAngle = _mapStartRotationAngle
	KeepRotationDistance()
	UpdateShader()
	_playerSprite.position = Vector2(WorldToScreenPosition(_playerMapPosition).x, WorldToScreenPosition(_playerMapPosition).y - 32)
	
	material.set_shader_parameter("opponentMarkerPosition", _opponentMapPosition)
	material.set_shader_parameter("opponentMarkerRadius", _opponentMapMarkerRadius)
	material.set_shader_parameter("opponentMarkerColor", _opponentMapMarkerColor)

func _process(delta):
	HandleInput()
	HandleSprites()
	UpdateShader()
	
	material.set_shader_parameter("playerMarkerPosition", _playerMapPosition)
	material.set_shader_parameter("playerMarkerRadius", _playerMapMarkerRadius)
	material.set_shader_parameter("playerMarkerColor", _playerMapMarkerColor)
	
	if(_debugContainer.ReturnShowDebugInfo()):
		_debugContainer.ShowDebugInfo(texture, _mapPosition, _mapRotationAngle, _playerMapPosition, WorldToScreenPosition(_opponentMapPosition))

func HandleInput():
	RotateMap(Input.get_action_strength("Rotate_Left") - Input.get_action_strength("Rotate_Right"), Input.is_action_pressed("Pitch"))
	
	var direction : Vector3 = Vector3(	Input.get_action_strength("Right") - Input.get_action_strength("Left"), 
										Input.get_action_strength("Ascend") - Input.get_action_strength("Descend"), 
										Input.get_action_strength("Backward") - Input.get_action_strength("Forward")
										)
	
	MoveMap(direction)

func RotateMap(rotationDirection : int, alterPitch : bool = false):
	if(rotationDirection == 0): return
	
	var incrementAngle : float = rotationDirection * _mapRotationSpeed * get_process_delta_time()
	
	if(alterPitch):
		UpdateAngleRotation("x", incrementAngle)
	else:
		UpdateAngleRotation("y", incrementAngle)
		KeepRotationDistance()

func KeepRotationDistance():
	var relPos : Vector3 = Vector3(_rotationRadius * sin(_mapRotationAngle.y), _mapPosition.y - _playerMapPosition.y, _rotationRadius * cos(_mapRotationAngle.y))
	_mapPosition = _playerMapPosition + relPos

func MoveMap(dir : Vector3):
	if(dir == Vector3.ZERO): return
	
	dir = dir.normalized()
	var forward : Vector3 = ReturnForward(_mapRotationAngle.y) * dir.z
	var right : Vector3 = ReturnRight(_mapRotationAngle.y) * dir.x
	var height : float = dir.y * _mapVerticalMovementSpeed
	
	var zoomLevel : float = _mapPosition.y;
	height *= (1.0 + zoomLevel)
	
	_velocity = (((forward + right) * _mapHorizontalMovementSpeed) + 
				   Vector3(0, height, 0)) * get_process_delta_time()
	
	_playerMapPosition += _velocity
	_mapPosition += _velocity
	_mapPosition.y = clamp(_mapPosition.y, _minMaxMapHeight.x, _minMaxMapHeight.y)

func UpdateShader():
	var yawMatrix : Basis = Basis(
		Vector3(cos(_mapRotationAngle.y), -sin(_mapRotationAngle.y), 0.0),
		Vector3(sin(_mapRotationAngle.y), cos(_mapRotationAngle.y), 0.0),
		Vector3(0.0,0.0,1.0)
	)
	
	var pitchMatrix : Basis = Basis(
		Vector3(1, 0 , 0),
		Vector3(0, cos(_mapRotationAngle.x), -sin(_mapRotationAngle.x)),
		Vector3(0, sin(_mapRotationAngle.x), cos(_mapRotationAngle.x))
	)
	
	var rotationMatrix : Basis = yawMatrix * pitchMatrix
	
	var translationMatrix : Basis = Basis(
		Vector3(1.0, 0.0, 0.0),
		Vector3(0.0, 1.0, 0),
		Vector3(_mapPosition.x * exp(_mapPosition.y), _mapPosition.z * exp(_mapPosition.y), exp(_mapPosition.y))
	)
	
	_finalMatrix =  translationMatrix * rotationMatrix 
	
	material.set_shader_parameter("mapMatrix", _finalMatrix)

func HandleSprites():
	var in2DMap : Vector2 = Vector2(_playerMapPosition.x, _playerMapPosition.z)
	var in2DOpponent : Vector2 = Vector2(_opponentMapPosition.x, _opponentMapPosition.z)
	var distance : float = in2DOpponent.distance_to(in2DMap) * 1026
	
	if(distance <= 200):
		var state : int = 7
		if(distance > 100 and distance <= 150):
			state = 3
		elif(in2DOpponent.distance_to(in2DMap) * 1026 <= 100):
			state = 0
		
		print(in2DOpponent.distance_to(in2DMap) * 1026)
		_opponentSprite.position = Vector2(WorldToScreenPosition(_opponentMapPosition).x, WorldToScreenPosition(_opponentMapPosition).y - _opponentSprite.region_rect.size.y)
		_opponentSprite.region_rect.position.y = 32 * state
		if(_opponentSprite.visible == false):
			_opponentSprite.visible = true
	else:
		_opponentSprite.visible = false

func ReturnForward(angle : float) -> Vector3: return Vector3(sin(angle), 0, cos(angle))
func ReturnRight(angle : float) -> Vector3: return Vector3(cos(angle), 0, -sin(angle))

func UpdateAngleRotation(axis : String, incrementAngle : float):
	_mapRotationAngle[axis] += incrementAngle
	_mapRotationAngle[axis] = WrapAngle(_mapRotationAngle[axis])

func WrapAngle(angle : float) -> float: 
	if(rad_to_deg(angle) > 360):
		return angle - deg_to_rad(360)
	elif(rad_to_deg(angle) < 0):
		return angle + deg_to_rad(360)
	return angle

func WorldToScreenPosition(world_pos : Vector3) -> Vector2:
	var transformed_pos = _finalMatrix.inverse() * Vector3(world_pos.x, world_pos.z, 1.0)
	if (transformed_pos.z < 0.0):
		return Vector2(-1000, -1000)  
	
	var screen_pos = Vector2(transformed_pos.x / transformed_pos.z, transformed_pos.y / transformed_pos.z) 
	screen_pos = (screen_pos + Vector2(0.5, 0.5)) * Vector2(480, 360)
	return screen_pos.floor()
