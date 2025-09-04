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
var stump_scene = preload("res://Scenes/stump.tscn")
var rock_scene = preload("res://Scenes/rock.tscn")
var barrel_scene = preload("res://Scenes/barrel.tscn")
var bird_scene = preload("res://Scenes/bird.tscn")
var obstacle_types := [stump_scene, rock_scene, barrel_scene]
var obstacles : Array
var bird_heighs := [200,390]
var last_obs
var ground_height : int



func _ready() -> void:
	screen_size = get_window().size
	ground_height = $Ground.get_node("Sprite2D").texture.get_height()
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

func generate_obs(): # ฟังก์ชันสร้างอุปสรรคใหม่
	if obstacles.is_empty(): # เช็คว่าตอนนี้ยังไม่มีอุปสรรคอยู่ (ลิสต์ว่างอยู่)
	# สุ่มเลือกชนิดอุปสรรคจาก obstacle_types
		var obs_type = obstacle_types[randi() % obstacle_types.size()]
		var obs # ประกาศตัวแปร obs ไว้เก็บอุปสรรค
		obs = obs_type.instantiate() # สร้าง instance (ส าเนา) ของ scene อุปสรรคที่เลือกมา
		# ดึงความสูงของสไปรท์ (texture height) ของอุปสรรค
		var	obs_height = obs.get_node("Sprite2D").texture.get_height()
		# ดึงค่า scale (การขยาย) ของสไปรท์
		var obs_scale = obs.get_node("Sprite2D").scale
		# ก าหนดต าแหน่งแกน X ของอุปสรรค# เริ่มต้นจากขอบขวาของจอ (screen_size.x)
		# บวกค่า score เพื่อให้มันเลื่อนไกลขึ้นตามคะแนน (หรือระยะที่เล่นไปแล้ว)
		# +100 ไว้เป็นระยะ buffer กันไม่ให้มันโผล่มาชิดเกินไป
		var obs_x : int = screen_size.x + score + 100
		# ก าหนดต าแหน่งแกน Y ของอุปสรรค
		# เริ่มจากขอบล่างของจอ (screen_size.y)
		# ลบความสูงพื้น (ground_height)
		# ลบครึ่งหนึ่งของความสูงจริงของอุปสรรค (ค านวณจาก obs_height * scale)
		# +5 ไว้เพื่อปรับเล็กน้อยไม่ให้จมลงไปในพื้น
		var obs_y : int = screen_size.y - ground_height - (obs_height * obs_scale.y / 2) + 5
		obs.position = Vector2i(obs_x, obs_y) # ตั้งต าแหน่ง (x, y) ให้กับอุปสรรคlast_obs = obs
		add_child(obs) # เพิ่มอุปสรรคเข้าไปใน scene tree เพื่อแสดงในเกมobstacles.append(obs) # เก็บ reference ของอุปสรรคไว้ในลิสต์ obstacles
