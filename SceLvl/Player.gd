extends Node2D
class_name Player

const ACC = 4
const TSP = 250
const DCC = 5
const MSP = 400
const GRV = 16
const JSP = -400

@onready
var sprite = $Sketchy
@onready
var animPl = $Sketchy/AnimationPlayer
@onready
var checks = $Checks
@onready
var checkC = $Checks/C

var asp = 0
var gsp = 0
var hsp = 0
var ang = 0
var hrd = 7.5
var vrd = 13
var isGrounded = false
var aState = 0 #0: Stand 1: Move 2: Roll 3: Duck
var dir = 1

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	airMove()
	sprite.flip_h = dir == -1
	anim()

func airMove():
	aState = 2
	if Input.is_action_just_pressed("A"):
		asp = JSP
		return
	if asp < JSP/2 and Input.is_action_just_released("A"):
		asp /= 2
	asp += GRV
	if asp > abs(JSP)*1.5:
		asp = abs(JSP)*1.5
		
	var InputDir = Input.get_axis("Left","Right")
	if InputDir:
		if hsp * sign(InputDir) < TSP:
			hsp = move_toward(hsp,TSP*InputDir,ACC*.75)
	else:
		hsp = move_toward(hsp,0,DCC*.75)
	global_position += Vector2(hsp,asp)/60

func floorMove():
	return

func getFloorAngle():
	return 0

func anim():
	match aState:
		2:
			sprite.rotate(PI/5*dir)
			animPl.play("roll")
		_:
			return
			animPl.play("run")
