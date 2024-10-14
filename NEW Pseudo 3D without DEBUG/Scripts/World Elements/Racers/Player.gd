#Player.gd
extends Racer

func Setup(mapSize : int):
	SetMapSize(mapSize)

func Update(mapForward : Vector3):
	if(_isPushedBack):
		ApplyCollisionBump()
	
	var nextPos : Vector3 = _mapPosition + ReturnVelocity()
	var nextPixelPos : Vector2i = Vector2i(ceil(nextPos.x), ceil(nextPos.z))
	
	if(_collisionHandler.IsCollidingWithWall(Vector2i(ceil(nextPos.x), ceil(_mapPosition.z)))):
		nextPos.x = _mapPosition.x 
		SetCollisionBump(Vector3(-sign(ReturnVelocity().x), 0, 0))
	if(_collisionHandler.IsCollidingWithWall(Vector2i(ceil(_mapPosition.x), ceil(nextPos.z)))):
		nextPos.z = _mapPosition.z
		SetCollisionBump(Vector3(0, 0, -sign(ReturnVelocity().z)))
	
	HandleRoadType(nextPixelPos, _collisionHandler.ReturnCurrentRoadType(nextPixelPos))
	
	SetMapPosition(nextPos)
	UpdateMovementSpeed()
	UpdateVelocity(mapForward)

func ReturnPlayerInput() -> Vector2:
	_inputDir.x = Input.get_action_strength("Left") - Input.get_action_strength("Right")
	_inputDir.y = -Input.get_action_strength("Forward")
	return Vector2(_inputDir.x, _inputDir.y)
