extends Sprite2D

@export_subgroup("Map Settings")
@export var _map : Sprite2D          # Sprite2D with the Pseudo 3D Shader
@export var _minMapHeight : float    # minimal distance the map has to the viewpoint
@export var _maxMapHeight : float    # maximum distance the map has to the viewpoint

@export_subgroup("Movement Settings")
@export var _rotation : float
@export var _rotationSpeed : float
@export var _rotationRadius : float
@export var _horizontalMovementSpeed : float
@export var _verticalMovementSpeed : float
@export var _mapPosition : Vector3

var _velocity : Vector3

@export_category("Debug Settings")
@export var _debugInfoLabel : Label

func _ready():
	pass

func _process(delta):
	var worldMatrix : Transform3D = ReturnTranslationMatrix() * ReturnYawMatrix() * ReturnHeightMatrix()
	_map.material.set_shader_parameter("mapMatrix", worldMatrix)

func ReturnTranslationMatrix() -> Transform3D:
	var translationMatrix : Transform3D
	translationMatrix.basis.x = Vector3(1.0, 0.0, 0.0)
	translationMatrix.basis.y = Vector3(0.0, 1.0, 0.0)
	translationMatrix.basis.z = Vector3(_mapPosition.x, _mapPosition.z, 1.0)
	return translationMatrix

func ReturnYawMatrix() -> Transform3D:
	var yawMatrix : Transform3D
	yawMatrix.basis.x = Vector3(-cos(_rotation), sin(_rotation), 0.0)
	yawMatrix.basis.y = Vector3(sin(_rotation), cos(_rotation), 0.0)
	yawMatrix.basis.z = Vector3(0.0, 0.0, 1.0)
	return yawMatrix

func ReturnHeightMatrix() -> Transform3D:
	var heightMatrix : Transform3D
	heightMatrix.basis.x = Vector3(1.0, 0.0, 0.0)
	heightMatrix.basis.y = Vector3(0.0, 0.0, exp(_mapPosition.y))
	heightMatrix.basis.z = Vector3(0.0, 1.0, 0.0)
	return heightMatrix

func ReturnForward(mapAngle : float) -> Vector3:
	return Vector3(sin(mapAngle), 0, cos(mapAngle))

func ReturnRight(mapAngle : float) -> Vector3:
	return Vector3(cos(mapAngle), 0, -sin(mapAngle))
