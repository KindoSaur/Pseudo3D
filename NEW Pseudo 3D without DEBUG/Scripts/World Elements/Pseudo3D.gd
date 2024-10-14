#Pseudo3D.gd
extends Sprite2D

@export_category("Map Settings : Rotation")
@export var _mapStartRotationAngle : Vector2
@export var _mapMaxRotationSpeed : float
@export var _mapAccelRotationSpeed : float
@export var _mapDeaccelRotationSpeed : float
@export var _rotationRadius : float
var _mapRotSpeed : float
var _currRotDir = 0

@export_category("Map Settings : Position")
@export var _mapVerticalPosition : float
var _mapPosition : Vector3
var _mapRotationAngle : Vector2
var _finalMatrix : Basis

func Setup(screenSize : Vector2, player : Racer):
	scale = screenSize / texture.get_size().x
	_mapPosition = Vector3(player.ReturnMapPosition().x, _mapVerticalPosition, player.ReturnMapPosition().z)
	_mapRotationAngle = _mapStartRotationAngle
	KeepRotationDistance(player)
	UpdateShader()

func Update(player : Racer):
	RotateMap(player.ReturnPlayerInput().x, player.ReturnMovementSpeed())
	KeepRotationDistance(player)
	UpdateShader()

func RotateMap(rotDir : int, speed : float):
	if(rotDir != 0 and abs(speed) > 0): AccelMapRotation(rotDir)
	else: DeaccelMapRotation()
	
	if(abs(_mapRotSpeed) > 0):
		var incrementAngle : float = _currRotDir * _mapRotSpeed * get_process_delta_time()
		_mapRotationAngle.y += incrementAngle
		_mapRotationAngle.y = WrapAngle(_mapRotationAngle.y)

func AccelMapRotation(rotDir : int):
	if(rotDir != _currRotDir and _mapRotSpeed > 0):
		DeaccelMapRotation()
		if(_mapRotSpeed == 0): _currRotDir = rotDir
	else:
		_mapRotSpeed += _mapAccelRotationSpeed * get_process_delta_time()
		_mapRotSpeed = min(_mapRotSpeed, _mapMaxRotationSpeed)
		_currRotDir = rotDir

func DeaccelMapRotation():
	if(abs(_mapRotSpeed) > 0):
		_mapRotSpeed -= _mapDeaccelRotationSpeed * get_process_delta_time()
		_mapRotSpeed = max(_mapRotSpeed, 0)

func KeepRotationDistance(racer : Racer):
	var relPos : Vector3 = Vector3((_rotationRadius / texture.get_size().x) * sin(_mapRotationAngle.y), 
									_mapPosition.y - racer.ReturnMapPosition().y, 
									(_rotationRadius / texture.get_size().x) * cos(_mapRotationAngle.y))
	_mapPosition = racer.ReturnMapPosition() + relPos

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

func WrapAngle(angle : float) -> float: 
	if(rad_to_deg(angle) > 360):
		return angle - deg_to_rad(360)
	elif(rad_to_deg(angle) < 0):
		return angle + deg_to_rad(360)
	return angle

func ReturnForward() -> Vector3: return Vector3(sin(_mapRotationAngle.y), 0, cos(_mapRotationAngle.y))
func ReturnWorldMatrix() -> Basis: return _finalMatrix
func ReturnMapRotation() -> float: return _mapRotationAngle.y
