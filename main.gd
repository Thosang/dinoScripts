extends Node2D
const DINO_START_POS := Vector2i(150,485)# ค่าตำแหน่งเริ่มต้นของ Dino (x=150, y=485)
const CAM_START_POS := Vector2i(576,324)# ค่าตำแหน่งเริ่มต้นของกล้อง (Camera2D)
var speed : float# ตัวแปรเก็บค่าความเร็ว ที่จะถูกกำหนดใหม่ทุกเฟรม
const START_SPEED : float = 10.0# ค่าความเร็วเริ่มต้นของ Dino
const SPEED_MODIFIER : int = 5000
const MAX_SPEED : int = 25 # ค่าความเร็วสูงสุดที่ Dino สามารถวิ่งได้
var screen_size : Vector2i
var score : int 
var running_start : bool

func _ready() -> void:
	screen_size = get_window().size
	new_game()

func new_game():
	score = 0
	$Dino.position = DINO_START_POS
	# ตั้งตำแหน่งของ Dino กลับไปที่ค่าเริ่มต้น (x=150, y=485)

	$Dino.velocity = Vector2i(0,0)
	# ตั้งค่า velocity ของ Dino ให้เป็นศูนย์ (ไม่เคลื่อนที่ในตอนเริ่ม)

	$Camera2D.position = CAM_START_POS
	# รีเซ็ตตำแหน่งของกล้องกลับไปที่ค่าเริ่มต้น (576,324)

	$Ground.position = Vector2i(0,0)
	# ตั้งตำแหน่งพื้น (Ground) ให้อยู่ที่ (0,0) (ไม่เคลื่อนที่ในตอนเริ่ม)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if $Camera2D.position.x - $Ground.position.x> screen_size.x * 1.5 :
			$Ground.position.x += screen_size.x
	
	if running_start:
		speed = START_SPEED +(score/SPEED_MODIFIER)
		if speed>=MAX_SPEED :
			speed = MAX_SPEED
		print(speed)
		score +=speed 
		show_score()  
		
		# ตั้งค่าความเร็วของ Dino เท่ากับค่าความเร็วเริ่มต้น (10.0)

		$Dino.position.x += speed
		# ขยับตำแหน่งของ Dino ทางแกน X ไปข้างหน้า (วิ่งไปเรื่อย ๆ)

		$Camera2D.position.x += speed
		# ขยับกล้องตาม Dino ไปทางแกน X เพื่อให้ Dino อยู่กลางจอ
	else:
		if Input.is_action_just_pressed("jump"):
			running_start=true
			$HUD/StartLabel.hide()
			$Dino.velocity.y = $Dino.JUMP_SPEED  # บังคับให้กระโดดทันที
			$Dino/JumpSound.play()# เล่นเสียงกระโดดจาก Node ที่ชื่อ JumpSound
			$Dino/AnimatedSprite2D.play("jump")
func show_score() :
	$HUD/ScoreLabel.text="SCORE : " + str(score)
