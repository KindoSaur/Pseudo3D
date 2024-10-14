#Racer.gd
class_name Racer
extends WorldElement

var _inputDir : Vector2 = Vector2.ZERO

@export_category("Racer Movement Settings")
@export var _maxMovementSpeed : float = 120
@export var _movementAccel : float = 70
@export var _movementDeaccel : float = 120
var _currentMoveDirection : int = 0.0
var _movementSpeed : float = 0.0
var _speedMultiplier : float = 1.0
var _velocity : Vector3 = Vector3.ZERO
var _onRoadType : Globals.RoadType = Globals.RoadType.VOID

@export_category("Racer Collision Settings")
@export var _collisionHandler : Node
var _bumpDir : Vector3 = Vector3.ZERO
var _isPushedBack : bool = false
var _pushbackTime : float = 0.3
var _currPushbackTime : float = 0.0
var _bumpIntensity : float = 2

func ReturnMovementSpeed() -> float: return _movementSpeed 
func ReturnCurrentMoveDirection() -> int: return _currentMoveDirection

func UpdateVelocity(mapForward : Vector3):
	_velocity = Vector3.ZERO
	if(_movementSpeed == 0): return
	var forward : Vector3 = mapForward * _currentMoveDirection
	_velocity = (forward * _movementSpeed) * get_process_delta_time()
func ReturnVelocity() -> Vector3: return _velocity

func HandleRoadType(nextPixelPos : Vector2i, roadType : Globals.RoadType):
	if(roadType == _onRoadType): return
	_onRoadType = roadType
	_spriteGFX.self_modulate.a = 1 
	
	match roadType:
		Globals.RoadType.VOID:
			_spriteGFX.self_modulate.a = 0
			_speedMultiplier = 0.0
		Globals.RoadType.ROAD:
			_speedMultiplier = 1.0
		Globals.RoadType.GRAVEL:
			_speedMultiplier = 0.9
		Globals.RoadType.OFF_ROAD:
			_speedMultiplier = 0.9
		Globals.RoadType.SINK:
			_spriteGFX.self_modulate.a = 0
			_speedMultiplier = 0.1
		Globals.RoadType.WALL:
			_speedMultiplier = _speedMultiplier

func ReturnOnRoadType() -> Globals.RoadType: return _onRoadType

func UpdateMovementSpeed():
	if(_inputDir.y != 0):
		if(_inputDir.y != _currentMoveDirection and _movementSpeed > 0): Deaccelerate()
		else: Accelerate()
	else:
		if(abs(_movementSpeed) > 0): Deaccelerate()

func Accelerate():
	_movementSpeed += _movementAccel * get_process_delta_time()
	_movementSpeed = min(_movementSpeed, _maxMovementSpeed * _speedMultiplier)
	if(_currentMoveDirection == _inputDir.y): return
	_currentMoveDirection = _inputDir.y

func Deaccelerate():
	_movementSpeed -= _movementDeaccel * get_process_delta_time()
	_movementSpeed = max(_movementSpeed, 0)
	if(_movementSpeed == 0 and _currentMoveDirection != _inputDir.y):
		_currentMoveDirection = _inputDir.y

func SetCollisionBump(bumpDir : Vector3):
	if(!_isPushedBack):
		_bumpDir = bumpDir
		_isPushedBack = true
		_currPushbackTime = _pushbackTime

func ApplyCollisionBump():
	_currPushbackTime -= get_process_delta_time()
	if(_currPushbackTime <= 0.0):
		_isPushedBack = false
	else:
		var bumpVelocity : Vector3 = _bumpDir * (_bumpIntensity * (_currPushbackTime / _pushbackTime))
		Deaccelerate()
		SetMapPosition(_mapPosition + bumpVelocity)
