extends Node2D
class_name Player

const ACC = 3
const TSP = 360
const DCC = 3
const SKD = 27
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
@onready
var checkA = $Checks/A
@onready
var checkB = $Checks/B
@onready
var checkD = $Checks/D
@onready
var checkE = $Checks/E

var asp = 0
var gsp = 0
var hsp = 0
var ang = 0
var hrd = 7.5
var vrd = 13
var isGrounded = false
var aState = 0 #0: Stand 1: Move 2: Roll 3: Duck 4: skid
var dir = 1

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if isGrounded:
		floorMove()
	else:
		airMove()
	sprite.flip_h = dir == -1
	anim()

func airMove():
	vrd = 8
	checkA.target_position.y = vrd
	checkB.target_position.y = vrd
	checks.rotation = 0
	aState = 2
	if asp < JSP/2 and Input.is_action_just_released("A"):
		asp /= 2
	asp += GRV
	if asp > abs(JSP)*1.5:
		asp = abs(JSP)*1.5
		
	var InputDir = Input.get_axis("Left","Right")
	if InputDir:
		if hsp * sign(InputDir) < TSP:
			hsp = move_toward(hsp,TSP*InputDir,ACC)
	else:
		hsp = move_toward(hsp,0,DCC)
		
	#Handle Walls
	global_position += Vector2(hsp,asp)/60
	if asp > 0:
		checkFloor()

func floorMove():
	vrd = 13
	checkA.target_position.y = vrd*1.7
	checkB.target_position.y = vrd*1.7
	checks.rotation = 0
	aState = 0
	var InputDir = Input.get_axis("Left","Right")
	if abs(gsp)>ACC*2:
		aState = 1
	if InputDir:
		dir = sign(InputDir)
		if gsp * sign(InputDir) < TSP:
			gsp = move_toward(gsp,TSP*InputDir,ACC)
		if sign(gsp*InputDir) < 0:
			aState = 4
			gsp = move_toward(gsp,TSP*InputDir,SKD)
	else:
		gsp = move_toward(gsp,0,DCC)
		
	#Handle Jumping
	if Input.is_action_just_pressed("A"):
		hsp = Vector2.from_angle(ang).x*gsp
		asp = Vector2.from_angle(ang).y*gsp
		asp -= Vector2.from_angle(ang-PI/2).y*JSP
		vrd = 8
		isGrounded = false
		Sounds.playSound(0)
		return
	#Wall Collisions
	var result = checkWallGrounded()
	if result:
		var signSpd = sign(gsp)
		gsp = floor(global_position.distance_to(result)*signSpd-(hrd*signSpd))*60
	global_position += Vector2.from_angle(ang+0)*gsp/60
	checkFloor()
	if isGrounded == false:
		hsp = Vector2.from_angle(ang).x*gsp
		asp = Vector2.from_angle(ang).y*gsp

func getFloorAngle():
	return 0

func Aground():
	var pt = checkA.get_collision_point()
	var normal = checkA.get_collision_normal()
	var angle = normal.angle()+PI/2
	ang = angle
	global_position.y = pt.y-vrd #+1

func Bground():
	var pt = checkB.get_collision_point()
	var normal = checkB.get_collision_normal()
	var angle = normal.angle()+PI/2
	ang = angle
	global_position.y = pt.y-vrd #+1

func checkWallGrounded():
	var movesTo = Vector2.from_angle(ang)*gsp/60
	checkC.target_position = Vector2(hrd*sign(movesTo.x),0)+movesTo
	if checkC.is_colliding():
		return checkC.get_collision_point()
	return false

func checkWallArial():
	var movesTo = Vector2(hsp,asp)/60
	checkC.target_position = Vector2(hrd*sign(movesTo.x),0)+movesTo
	if checkC.is_colliding():
		return checkC.get_collision_point()
	return false

func checkFloor():
	isGrounded = checkA.is_colliding() or checkB.is_colliding()
	if isGrounded:
		if checkA.is_colliding() and checkB.is_colliding():
			if checkA.get_collision_point().y < checkB.get_collision_point().y:
				Aground()
			else:
				Bground()
		elif checkA.is_colliding():
			Aground()
		else:
			Bground()

func anim():
	match aState:
		0:
			animPl.play("idle")
			sprite.rotation = 0
			
		2:
			sprite.rotate(PI/5*dir)
			animPl.play("roll")
		1:
			sprite.rotation = ang
			if gsp > TSP - 20:
				animPl.play("coast")
			else:
				animPl.play("run")
			animPl.speed_scale = sqrt(abs(gsp/TSP))
		4:
			sprite.rotation = ang
			animPl.play("skid")
		_:
			return
			animPl.play("run")
