#AnimationHandler.gd
extends Node

@export_category("Player Animation Settings")
@export var _effectsPlayer : AnimationPlayer
@export var _roadRoughness : int = 3
var _currBounceTime : float = 0.0
var _bouncedUp : bool = false

var _player : Racer
var _previousHandledRoadType : Globals.RoadType = Globals.RoadType.ROAD
var _originalPlayerSpriteYPos : float = 0

@export var _specialWheelEffect : Array[Sprite2D]
var _firstTimeSink : bool = true

func Setup(player : Racer):
	_player = player
	_originalPlayerSpriteYPos = player.ReturnSpriteGraphic().position.y

func Update():
	if(_effectsPlayer.get_parent().z_index != _player.ReturnSpriteGraphic().z_index + 1):
		_effectsPlayer.get_parent().z_index = _player.ReturnSpriteGraphic().z_index + 1
	
	if(_player.ReturnOnRoadType() != _previousHandledRoadType):
		PlaySpecificEffectAnimation(_player.ReturnOnRoadType())
	
	if(_player.ReturnOnRoadType() != Globals.RoadType.SINK):
		PlayerRoadBounceAnimation()

func PlaySpecificEffectAnimation(roadType : Globals.RoadType):
	var animName : String
	_effectsPlayer.get_parent().visible = true
	_specialWheelEffect[0].visible = false
	_specialWheelEffect[1].visible = false
	
	match roadType:
		Globals.RoadType.ROAD:
			_effectsPlayer.get_parent().visible = false
			_firstTimeSink = true
		Globals.RoadType.GRAVEL:
			_effectsPlayer.get_parent().visible = true
			_specialWheelEffect[0].visible = true
			_specialWheelEffect[1].visible = true
			animName = "Gravel"
			_firstTimeSink = true
		Globals.RoadType.OFF_ROAD:
			animName = "Idle_Off_Road" if _player.ReturnMovementSpeed() < 1 else "Driving_Off_Road"
			_firstTimeSink = true
		Globals.RoadType.WALL:
			if(_effectsPlayer.current_animation == "Sink_Anim"):
				_player.ReturnSpriteGraphic().self_modulate.a = 0
			else:
				_effectsPlayer.get_parent().visible = false
		Globals.RoadType.SINK:
			if(_firstTimeSink):
				_specialWheelEffect[0].visible = true
				_specialWheelEffect[1].visible = true
				animName = "Sink_Splash"
	animName += "_Anim"
	_previousHandledRoadType = roadType
	
	if(animName == _effectsPlayer.current_animation or !_effectsPlayer.has_animation(animName)): return
	_effectsPlayer.stop()
	_effectsPlayer.play(animName)

func PlayerRoadBounceAnimation():
	_currBounceTime += get_process_delta_time() * _player.ReturnMovementSpeed()
	
	if(_currBounceTime > 1): 
		_currBounceTime = 0
		_bouncedUp = !_bouncedUp
	
	if(_bouncedUp):
		_player.ReturnSpriteGraphic().position.y = _originalPlayerSpriteYPos - _roadRoughness
	else:
		_player.ReturnSpriteGraphic().position.y = _originalPlayerSpriteYPos

func SetFirstTimeSink(input : bool): _firstTimeSink = input

func PlaySinkAnimation(): _effectsPlayer.play("Sink_Anim")
