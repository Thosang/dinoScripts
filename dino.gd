extends CharacterBody2D
# ก าหนดให้สคริปต์นี้สืบทอดคุณสมบัติจาก CharacterBody2D (ตัวละครที่มีฟิสิกส์พื้นฐาน)
const GRAVITY : int = 4200# ประกาศค่าคงที่ GRAVITY = 4200 (แรงโน้มถ่วงในแนวดิ่ง กดตัวละครลงเมื่อตอนตก)
const JUMP_SPEED : int = -1800
# ประกาศค่าคงที่ JUMP_SPEED = -1800 (ความเร็วตอนกระโดดขึ้น ใช้ค่าเป็นลบเพราะแกน Y บนหน้าจอชี้ลง)
func _physics_process(delta: float) -> void: # ฟังก์ชันนี้จะถูกเรียกทุกเฟรมที่เกี่ยวข้องกับฟิสิกส์
# delta คือเวลาที่ผ่านไปในหนึ่งรอบการประมวลผล (ช่วยให้การเคลื่อนที่สมูทไม่ขึ้นกับ FPS)
	velocity.y += GRAVITY * delta
	# เพิ่มค่าความเร็วแกน Y ตามแรงโน้มถ่วง ท าให้ตัวละครตกลงเรื่อย ๆ
	if is_on_floor():
		if not get_parent().running_start:
			$AnimatedSprite2D.play("idle")
		else:
			
			if Input.is_action_just_pressed("jump"):
				$RunCol.disabled = false
				$DuckCol.disabled = true
				
				# ตรวจสอบว่าผู้เล่นกดปุ่ม "jump" (และเพิ่งกดครั้งเดียวในตอนนี้ ไม่ใช่กดค้าง)
				velocity.y = JUMP_SPEED# ตั้งค่าความเร็วแกน Y ให้เป็นความเร็วกระโดด (ติดลบ → กระโดดขึ้น)
				$JumpSound.play()# เล่นเสียงกระโดดจาก Node ที่ชื่อ JumpSound
				$AnimatedSprite2D.play("jump")
			elif Input.is_action_pressed("duck"):
				$RunCol.disabled = true
				$DuckCol.disabled = false
				$AnimatedSprite2D.play("duck")
			else:
				$RunCol.disabled = false
				$DuckCol.disabled = true
				$AnimatedSprite2D.play("run")
	move_and_slide()# ฟังก์ชันช่วยจัดการการเคลื่อนที่ และการชนของตัวละครโดยอัตโนมัติ

