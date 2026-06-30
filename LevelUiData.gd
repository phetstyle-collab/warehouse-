extends RefCounted
class_name LevelUiData

const DATA := {
	"level_1": {
		"title": "ด่าน 1: เริ่มระบบโรงงาน",
		"lesson": "บทที่ 1: Sequence",
		"objectives": [
			{"id": "start_spawner", "text": "เปิดเครื่องปล่อยกล่อง", "rule": {"action": "START_SPAWNER", "count": 1}},
			{"id": "start_conveyor", "text": "เปิดสายพาน", "rule": {"action": "START_CONVEYOR", "count": 1}},
			{"id": "deliver_box", "text": "ส่งกล่องถึงปลายทาง", "rule": {"destroyed_total": 1}},
		],
		"stars": [
			"ผ่านภารกิจหลัก",
			"ใช้ start(spawner); และ start(conveyor); ครบ",
			"ไม่มี syntax error",
		],
	},
	"level_2": {
		"title": "ด่าน 2: หยุดระบบเมื่อเซนเซอร์ตรวจพบ",
		"lesson": "บทที่ 2: Event และ Wait",
		"objectives": [
			{"id": "start_system", "text": "เปิด spawner และ conveyor", "rule": {"all_actions": {"START_SPAWNER": 1, "START_CONVEYOR": 1}}},
			{"id": "detect_weight", "text": "รอให้ weight sensor ตรวจพบกล่อง", "rule": {"sensor": "weight", "count": 1}},
			{"id": "stop_system", "text": "หยุดระบบหลังเจอกล่อง", "rule": {"all_actions": {"STOP_SPAWNER": 1, "STOP_CONVEYOR": 1}}},
		],
		"stars": [
			"หยุดระบบได้หลัง sensor ทำงาน",
			"ใช้ wait กับ stop ครบ",
			"ไม่มี syntax error",
		],
	},
	"level_3": {
		"title": "ด่าน 3: สั่งแขนกลตามลำดับ",
		"lesson": "บทที่ 3: Sequence และ Action Sync",
		"objectives": [
			{"id": "rotate_once", "text": "หมุนแขนกลครั้งแรก", "rule": {"action": "ROTATE_ARM", "count": 1}},
			{"id": "wait_done", "text": "รอให้คำสั่งก่อนหน้าจบ", "rule": {"action_done": "ROTATE_ARM", "count": 1}},
			{"id": "rotate_twice", "text": "หมุนแขนกลครบ 2 ครั้ง", "rule": {"action": "ROTATE_ARM", "count": 2}},
		],
		"stars": [
			"หมุนแขนกลครบ 2 ครั้ง",
			"มี wait until action(done)",
			"ไม่มี syntax error",
		],
	},
	"level_4": {
		"title": "ด่าน 4: หยิบและวางกล่อง",
		"lesson": "บทที่ 4: Sequence หลายขั้น",
		"objectives": [
			{"id": "detect_box", "text": "ให้เซนเซอร์น้ำหนักตรวจพบกล่อง", "rule": {"sensor": "weight", "count": 1}},
			{"id": "stop_system", "text": "หยุด spawner และ conveyor ก่อนหยิบ", "rule": {"all_actions": {"STOP_SPAWNER": 1, "STOP_CONVEYOR": 1}}},
			{"id": "pick_drop", "text": "หยิบและวางกล่องสำเร็จ", "rule": {"all_actions": {"PICK_BOX": 1, "DROP_BOX": 1}}},
		],
		"stars": [
			"หยิบและวางกล่องสำเร็จ",
			"ใช้คำสั่ง wait ได้ถูกจังหวะ",
			"ไม่มี syntax error",
		],
	},
	"level_5": {
		"title": "ด่าน 5: แยกกล่องหนัก",
		"lesson": "บทที่ 5: Loop และ If/Else",
		"objectives": [
			{"id": "start_system", "text": "เปิดระบบให้เริ่มทำงาน", "rule": {"all_actions": {"START_SPAWNER": 1, "START_CONVEYOR": 1}}},
			{"id": "handle_heavy", "text": "หยิบกล่องหนักอย่างน้อย 1 กล่อง", "rule": {"action": "PICK_BOX", "count": 1}},
			{"id": "route_heavy", "text": "ส่งกล่องหนักไปปลายทางที่ถูกต้อง", "rule": {"destroyer": "destroyer2", "count": 1}},
		],
		"stars": [
			"แยกกล่องหนักได้สำเร็จ",
			"ใช้ while true และ if/else",
			"ไม่มี syntax error",
		],
	},
	"level_6": {
		"title": "ด่าน 6: คัดกล่องหนักไปถัง 2",
		"lesson": "บทที่ 6: Condition Routing",
		"objectives": [
			{"id": "start_system", "text": "เปิดระบบให้เริ่มทำงาน", "rule": {"all_actions": {"START_SPAWNER": 1, "START_CONVEYOR": 1}}},
			{"id": "check_weight", "text": "ตรวจน้ำหนักของกล่อง", "rule": {"sensor": "weight", "count": 1}},
			{"id": "heavy_to_d2", "text": "ส่งกล่องหนักไป destroyer2", "rule": {"destroyer": "destroyer2", "count": 1}},
		],
		"stars": [
			"ส่งกล่องหนักไปถัง 2 ได้",
			"ใช้ if (weight > 5)",
			"ไม่มี syntax error",
		],
	},
	"level_7": {
		"title": "ด่าน 7: แยกหนักและเบา",
		"lesson": "บทที่ 7: If/Else Routing",
		"objectives": [
			{"id": "heavy_route", "text": "มีกล่องหนักไป destroyer2", "rule": {"destroyer": "destroyer2", "count": 1}},
			{"id": "light_route", "text": "มีกล่องเบาไป destroyer3", "rule": {"destroyer": "destroyer3", "count": 1}},
			{"id": "sort_two_types", "text": "คัดแยกได้อย่างน้อย 2 แบบ", "rule": {"all_destroyers": {"destroyer2": 1, "destroyer3": 1}}},
		],
		"stars": [
			"แยกหนักและเบาได้",
			"ใช้ if และ else ครบ",
			"ไม่มี syntax error",
		],
	},
	"level_8": {
		"title": "ด่าน 8: คัดแยกครบทั้งสายการผลิต",
		"lesson": "บทที่ 8: Sorting Challenge",
		"objectives": [
			{"id": "heavy_route", "text": "ส่งกล่องหนักไป destroyer2", "rule": {"destroyer": "destroyer2", "count": 1}},
			{"id": "light_route", "text": "ส่งกล่องเบาไป destroyer3", "rule": {"destroyer": "destroyer3", "count": 1}},
			{"id": "all_boxes_sorted", "text": "คัดแยกกล่องครบ 5 กล่อง", "rule": {"destroyed_total": 5}},
		],
		"stars": [
			"คัดแยกครบ 5 กล่อง",
			"ใช้ if และ else ครบ",
			"ไม่มี syntax error",
		],
	},
	# ============================================================
	# Tutorial Scenes — ไม่มี objectives/stars, แค่ฝึก Syntax
	# ============================================================
	"tutorial_1": {
		"title": "Tutorial 1: รู้จัก MiniC",
		"lesson": "Syntax & การพิมพ์คำสั่ง",
		"is_tutorial": true,
		"objectives": [],
		"stars": [],
		"tutorial_steps": [
			"1. พิมพ์คำสั่งตามที่เห็นในหน้าจอ",
			"2. กด RUN เพื่อดูผลลัพธ์",
			"3. ลองแก้ไขโค้ดดูว่าเกิดอะไรขึ้น",
		],
	},
}

static func get_level_data(level_id: String) -> Dictionary:
	if DATA.has(level_id):
		return DATA[level_id].duplicate(true)
	# fallback เฉพาะด่านจริงเท่านั้น (ไม่ fallback สำหรับ tutorial)
	if level_id.begins_with("tutorial"):
		return {
			"title": level_id,
			"lesson": "Tutorial Mode",
			"is_tutorial": true,
			"objectives": [],
			"stars": [],
			"tutorial_steps": ["พิมพ์โค้ดและกด RUN เพื่อดูผลลัพธ์"],
		}
	return DATA["level_1"].duplicate(true)
