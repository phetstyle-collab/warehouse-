extends CanvasLayer

const GUIDE_CATEGORIES := [
	{
		"id": "basic",
		"title": "คำสั่งพื้นฐาน",
		"summary": "เริ่มระบบ หยุดระบบ และรอให้เครื่องจักรพร้อมก่อนทำขั้นตอนต่อไป",
		"mission": "ภารกิจปัจจุบัน: ควบคุมการเริ่มและหยุดสายการผลิตให้ถูกลำดับ",
		"cards": [
			{
				"icon": "01",
				"title": "start(conveyor);",
				"desc": "เริ่มให้สายพานทำงานเพื่อพากล่องเคลื่อนไปยังจุดตรวจจับ",
				"code": "start(conveyor);\nwait until (weight(has_value));",
			},
			{
				"icon": "02",
				"title": "wait until (...);",
				"desc": "หยุดรอจนกว่าการกระทำหรือเซนเซอร์จะส่งค่าสำเร็จ",
				"code": "wait until (action(done));",
			},
			{
				"icon": "03",
				"title": "stop(spawner);",
				"desc": "หยุดปล่อยกล่องเมื่อถึงเวลาคัดแยกหรือจัดการแขนกล",
				"code": "stop(spawner);\nstop(conveyor);",
			},
		],
		"quick_code": "start(spawner);\nstart(conveyor);\nwait until (weight(has_value));\nstop(conveyor);",
		"quick_desc": "ตัวอย่างนี้เปิดระบบ ปล่อยกล่อง และรอให้เซนเซอร์น้ำหนักอ่านค่าก่อนหยุดสายพานเพื่อเตรียมตัดสินใจ",
	},
	{
		"id": "conveyor",
		"title": "สายพานและกล่อง",
		"summary": "ใช้ควบคุมการไหลของกล่องในคลังสินค้าอัตโนมัติ",
		"mission": "ภารกิจปัจจุบัน: จัดลำดับการเคลื่อนที่ของกล่องให้ไปถึงจุดคัดแยกอย่างปลอดภัย",
		"cards": [
			{
				"icon": "CV",
				"title": "start(spawner);",
				"desc": "เริ่มปล่อยกล่องเข้าสู่ระบบสายพาน",
				"code": "start(spawner);\nstart(conveyor);",
			},
			{
				"icon": "BX",
				"title": "stop(conveyor);",
				"desc": "หยุดสายพานชั่วคราวเมื่อกล่องถึงตำแหน่งที่ต้องการ",
				"code": "wait until (color(has_value));\nstop(conveyor);",
			},
			{
				"icon": "RT",
				"title": "จัดเส้นทางกล่อง",
				"desc": "วางคำสั่งหยุดและเริ่มใหม่ให้กล่องไม่ชนกันระหว่างการคัดแยก",
				"code": "stop(conveyor);\n# handle box here\nstart(conveyor);",
			},
		],
		"quick_code": "start(spawner);\nstart(conveyor);\nwait until (color(has_value));\nstop(conveyor);",
		"quick_desc": "โค้ดนี้ใช้เปิดระบบ ส่งกล่องไปยังเซนเซอร์สี และหยุดเมื่อกล่องถึงจุดตรวจ",
	},
	{
		"id": "arm",
		"title": "แขนกล",
		"summary": "ใช้หมุน หยิบ และวางกล่องในตำแหน่งใหม่ตามเงื่อนไขของระบบ",
		"mission": "ภารกิจปัจจุบัน: ใช้แขนกลหยิบกล่องหนักไปวางยังปลายทางอีกฝั่ง",
		"cards": [
			{
				"icon": "AR",
				"title": "rotate(arm(90));",
				"desc": "หมุนแขนกลตามองศาที่กำหนดก่อนหยิบหรือวางกล่อง",
				"code": "rotate(arm(90));\nwait until (action(done));",
			},
			{
				"icon": "PK",
				"title": "pick(box);",
				"desc": "สั่งให้แขนกลหยิบกล่องขึ้นจากสายพาน",
				"code": "pick(box);\nwait until (action(done));",
			},
			{
				"icon": "DP",
				"title": "drop(box);",
				"desc": "วางกล่องในตำแหน่งปลายทางหลังจากหมุนแขนกลไปถึงจุดหมาย",
				"code": "rotate(arm(-90));\ndrop(box);",
			},
		],
		"quick_code": "stop(conveyor);\nrotate(arm(90));\nwait until (action(done));\npick(box);\ndrop(box);",
		"quick_desc": "โค้ดนี้หยุดสายพานก่อน แล้วสั่งแขนกลหมุน หยิบ และวางกล่องตามลำดับที่ปลอดภัย",
	},
	{
		"id": "sensor",
		"title": "เซนเซอร์",
		"summary": "ใช้ตรวจค่าน้ำหนัก สี และสถานะก่อนตัดสินใจสั่งเครื่องจักร",
		"mission": "ภารกิจปัจจุบัน: อ่านค่าน้ำหนักและสีเพื่อเลือกเส้นทางที่ถูกต้อง",
		"cards": [
			{
				"icon": "WG",
				"title": "weight(has_value)",
				"desc": "เช็กว่าเซนเซอร์น้ำหนักอ่านค่าจากกล่องได้แล้วหรือยัง",
				"code": "wait until (weight(has_value));",
			},
			{
				"icon": "CL",
				"title": "color(has_value)",
				"desc": "รอจนเซนเซอร์สีตรวจจับข้อมูลจากกล่องสำเร็จ",
				"code": "wait until (color(has_value));",
			},
			{
				"icon": "OK",
				"title": "action(done)",
				"desc": "ใช้ตรวจว่าแขนกลหรือกลไกอื่นทำงานเสร็จแล้ว",
				"code": "wait until (action(done));",
			},
		],
		"quick_code": "wait until (weight(has_value));\nif (weight > 5) {\n    stop(conveyor);\n}",
		"quick_desc": "เมื่อเซนเซอร์น้ำหนักอ่านค่าได้แล้ว ระบบจึงใช้ค่า `weight` ตัดสินใจว่าจะหยุดสายพานหรือไม่",
	},
	{
		"id": "if_else",
		"title": "เงื่อนไข if / else",
		"summary": "ใช้ให้ระบบเลือกทำงานต่างกันตามข้อมูลที่อ่านได้จากเซนเซอร์",
		"mission": "ภารกิจปัจจุบัน: แยกกล่องหนักและกล่องเบาด้วยตรรกะเงื่อนไข",
		"cards": [
			{
				"icon": "IF",
				"title": "if (weight > 5)",
				"desc": "สั่งงานเมื่อกล่องมีน้ำหนักมากกว่าเกณฑ์ที่กำหนด",
				"code": "if (weight > 5) {\n    stop(conveyor);\n}",
			},
			{
				"icon": "EL",
				"title": "else",
				"desc": "กำหนดเส้นทางสำรองเมื่อเงื่อนไขแรกไม่เป็นจริง",
				"code": "else {\n    start(conveyor);\n}",
			},
			{
				"icon": "LG",
				"title": "เปรียบเทียบค่า",
				"desc": "ใช้ >, <, ==, >=, <= เพื่อเช็กข้อมูลจากเซนเซอร์",
				"code": "if (weight <= 5) {\n    # light box route\n}",
			},
		],
		"quick_code": "if (weight > 5) {\n    pick(box);\n} else {\n    start(conveyor);\n}",
		"quick_desc": "ถ้ากล่องหนักให้แขนกลหยิบออก แต่ถ้ากล่องเบาให้ปล่อยผ่านต่อไปบนสายพาน",
	},
	{
		"id": "loop",
		"title": "ลูป while",
		"summary": "ใช้สั่งให้ระบบทำงานซ้ำกับกล่องทุกใบจนกว่าผู้เล่นจะหยุดลูปเอง",
		"mission": "ภารกิจปัจจุบัน: คัดแยกกล่องต่อเนื่องหลายใบในสายการผลิตเดียวกัน",
		"cards": [
			{
				"icon": "WH",
				"title": "while true { ... }",
				"desc": "วนคำสั่งซ้ำตลอดเวลา เหมาะกับด่านที่มีกล่องเข้ามาเรื่อย ๆ",
				"code": "while true {\n    wait until (weight(has_value));\n}",
			},
			{
				"icon": "LP",
				"title": "วางขั้นตอนในลูป",
				"desc": "ภายในลูปควรมีการอ่านเซนเซอร์ก่อนทุกครั้ง แล้วค่อยสั่ง if / else",
				"code": "while true {\n    wait until (color(has_value));\n    # decide route\n}",
			},
			{
				"icon": "CK",
				"title": "ลูปที่ปลอดภัย",
				"desc": "ใช้ wait until หรือเงื่อนไขหยุดเพื่อไม่ให้แขนกลทำงานซ้อนกัน",
				"code": "wait until (action(done));",
			},
		],
		"quick_code": "while true {\n    wait until (weight(has_value));\n    if (weight > 5) {\n        pick(box);\n    }\n}",
		"quick_desc": "ลูปนี้ทำให้ระบบตรวจน้ำหนักทุกกล่อง และสั่งแขนกลทำงานเฉพาะเมื่อกล่องหนักเกินเกณฑ์",
	},
	{
		"id": "example",
		"title": "ตัวอย่างโค้ด",
		"summary": "ดูตัวอย่างการใช้คำสั่งหลายกลุ่มร่วมกันในภารกิจเดียว",
		"mission": "ภารกิจปัจจุบัน: ต่อคำสั่ง Mini-C ให้ครบทั้งเริ่มระบบ ตรวจค่า และคัดแยก",
		"cards": [
			{
				"icon": "EX",
				"title": "เปิดระบบ",
				"desc": "เริ่มจากปล่อยกล่องและเปิดสายพานเพื่อให้กล่องเข้าโซนเซนเซอร์",
				"code": "start(spawner);\nstart(conveyor);",
			},
			{
				"icon": "SN",
				"title": "อ่านค่า",
				"desc": "รอให้เซนเซอร์น้ำหนักส่งค่ามาก่อนทุกครั้ง",
				"code": "wait until (weight(has_value));",
			},
			{
				"icon": "GO",
				"title": "ตัดสินใจและคัดแยก",
				"desc": "ใช้ if / else กำหนดว่ากล่องจะถูกหยิบหรือปล่อยผ่าน",
				"code": "if (weight > 5) {\n    pick(box);\n}",
			},
		],
		"quick_code": "start(spawner);\nstart(conveyor);\nwhile true {\n    wait until (weight(has_value));\n    if (weight > 5) {\n        stop(conveyor);\n        rotate(arm(90));\n        pick(box);\n        drop(box);\n        start(conveyor);\n    }\n}",
		"quick_desc": "ตัวอย่างนี้รวมการเปิดระบบ ลูปอ่านน้ำหนัก และการคัดแยกกล่องหนักด้วยแขนกลไว้ในชุดเดียว",
	},
	{
		"id": "errors",
		"title": "ข้อผิดพลาดที่พบบ่อย",
		"summary": "ช่วยเช็กจุดที่นักเรียนมักลืมก่อนส่งภารกิจ",
		"mission": "ภารกิจปัจจุบัน: ตรวจโค้ดของคุณก่อนกดรันหรือส่งคำตอบ",
		"cards": [
			{
				"icon": "ER",
				"title": "ลืม wait until",
				"desc": "ถ้าไม่รอให้เซนเซอร์หรือแขนกลเสร็จก่อน คำสั่งถัดไปอาจทำงานผิดจังหวะ",
				"code": "wait until (action(done));",
			},
			{
				"icon": "SC",
				"title": "ลืมปิดเครื่องหมาย ;",
				"desc": "คำสั่งส่วนใหญ่ต้องลงท้ายด้วย ; เพื่อให้ Mini-C อ่านครบ",
				"code": "start(conveyor);",
			},
			{
				"icon": "BL",
				"title": "ลืม else หรือวงเล็บ",
				"desc": "เงื่อนไข if / else ต้องมีวงเล็บและบล็อกคำสั่งครบเพื่อให้ตรรกะชัดเจน",
				"code": "if (weight > 5) {\n    stop(conveyor);\n}",
			},
		],
		"quick_code": "# checklist\nwait until (...);\nif (...) { ... }\ncommand();",
		"quick_desc": "ก่อนส่งงานให้เช็กว่าโค้ดมีเครื่องหมาย ; ครบ รอเซนเซอร์ถูกจุด และจัดบล็อก if / else ชัดเจน",
	},
]

const QUEST_TEXT := {
	"quest.tscn": {
		"title": "ด่าน 1",
		"goal": "เปิดเครื่องปล่อยกล่องและสายพานให้ทำงาน",
		"steps": [
			"เริ่ม spawner เพื่อปล่อยกล่อง",
			"เริ่ม conveyor เพื่อให้กล่องเคลื่อนที่",
		],
		"concepts": ["start()", "ลำดับคำสั่ง"],
		"hints": [
			"เริ่มจาก start(spawner); และ start(conveyor);",
			"ด่านนี้ยังไม่ต้องใช้ wait หรือ if เขียนเพียงสองบรรทัดก็พอ",
		],
	},
	"quest_2.tscn": {
		"title": "ด่าน 2",
		"goal": "เปิดระบบและหยุดเมื่อกล่องถึงเซนเซอร์น้ำหนัก",
		"steps": [
			"เริ่ม spawner และ conveyor",
			"รอให้ weight sensor อ่านค่ากล่อง",
			"หยุด spawner และ conveyor หลังตรวจพบกล่อง",
		],
		"concepts": ["wait_until()", "stop()", "sensor"],
		"hints": [
			"ใช้ wait until (weight(has_value)); เพื่อรอเซนเซอร์",
			"เมื่อ sensor อ่านค่าได้แล้ว ให้สั่ง stop(spawner); และ stop(conveyor);",
		],
	},
	"quest_3.tscn": {
		"title": "ด่าน 3",
		"goal": "หมุนแขนกลเป็นลำดับโดยรอให้รอบแรกเสร็จก่อน",
		"steps": [
			"หมุนแขนกลครั้งที่ 1",
			"รอ action(done)",
			"หมุนแขนกลครั้งที่ 2",
		],
		"concepts": ["rotate()", "wait_until(action(done))"],
		"hints": [
			"จุดสำคัญคือ wait until (action(done));",
			"หมุนรอบแรกให้เสร็จก่อน แล้วค่อย rotate รอบที่ 2",
		],
	},
	"quest_4.tscn": {
		"title": "ด่าน 4",
		"goal": "ตรวจจับกล่อง หยุดระบบ และใช้แขนกลหยิบวางกล่อง",
		"steps": [
			"เริ่ม spawner และ conveyor",
			"รอ weight sensor ตรวจพบกล่อง",
			"หยุดระบบก่อนสั่งแขนกล",
			"หมุน หยิบ รอ และวางตามลำดับ",
		],
		"concepts": ["sensor", "stop()", "rotate()", "pick()", "drop()"],
		"hints": [
			"ใช้ทั้ง weight(has_value) และ action(done)",
			"ลำดับที่ปลอดภัยคือ stop ก่อน แล้วค่อย rotate, pick, wait, rotate, drop",
		],
	},
	"questtestspe.tscn": {
		"title": "ด่าน 5",
		"goal": "ถ้าน้ำหนักมากกว่า 5 ให้หยิบไปวางอีกปลายทาง",
		"steps": [
			"วนรอ weight sensor ตรวจพบกล่อง",
			"ถ้า weight > 5 ให้หยุดระบบ",
			"ใช้แขนกลหยิบและวางกล่องไปตำแหน่งใหม่",
			"เริ่มระบบต่อหลังจัดการกล่องแล้ว",
		],
		"concepts": ["while true", "if / else", "pick()", "drop()"],
		"hints": [
			"ต้องมี while true และ if (weight > 5)",
			"เริ่มลูปด้วยการรอ sensor ทุกครั้ง แล้วค่อยตัดสินใจว่าจะหยิบหรือปล่อยผ่าน",
		],
	},
	"questlevel5.tscn": {
		"title": "ด่าน 6",
		"goal": "คัดแยกกล่องหนักกว่า 5 ไปยังถังที่ 2",
		"steps": [
			"เปิด spawner และ conveyor",
			"ตรวจน้ำหนักกล่อง",
			"ถ้า weight > 5 ให้ส่งไปปลายทางที่ 2",
		],
		"concepts": ["weight", "if / else", "routing"],
		"hints": [
			"ระบบตรวจว่ากล่องในปลายทาง 2 ต้องมีน้ำหนักมากกว่า 5",
			"ถ้าจะย้ายด้วยแขนกล ให้รอ sensor ก่อน หยุด conveyor แล้วค่อยย้าย",
		],
	},
	"questlevel_6.tscn": {
		"title": "ด่าน 7",
		"goal": "แยกกล่องหนักและกล่องเบาไปคนละปลายทาง",
		"steps": [
			"ถ้า weight > 5 ให้ไปปลายทางหนัก",
			"ถ้าไม่ใช่ ใช้ else เพื่อจัดการกล่องเบา",
			"ต้องมีอย่างน้อยหนึ่งเงื่อนไขการคัดแยกที่ถูกต้อง",
		],
		"concepts": ["if / else", "สองเส้นทาง"],
		"hints": [
			"อย่าลืม else เพราะตัวตรวจต้องการโครงสร้างนี้",
			"กรณีหนักกับเบาควรมีปลายทางคนละแบบอย่างชัดเจน",
		],
	},
	"questlevel_7.tscn": {
		"title": "ด่าน 8",
		"goal": "คัดแยกกล่องทั้งหมด 5 กล่องตามน้ำหนัก",
		"steps": [
			"กล่อง weight > 5 ไปปลายทางหนัก",
			"กล่อง weight <= 5 ไปปลายทางเบา",
			"ผลรวมต้องคัดแยกครบทั้ง 5 กล่อง",
		],
		"concepts": ["if / else", "while true", "routing"],
		"hints": [
			"ต้องมี if (weight > 5) และ else",
			"ฝั่งหนักและเบาต้องมีจำนวนกล่องลงคนละปลายทางให้ครบ",
		],
	},
}

const QUEST_SCENE_ALIASES := {
	"Test.tscn": "quest.tscn",
	"test_2.tscn": "quest_2.tscn",
	"test_3.tscn": "quest_3.tscn",
	"test_4.tscn": "quest_4.tscn",
	"test_6.tscn": "questtestspe.tscn",
	"test_5.tscn": "questlevel5.tscn",
	"test_7.tscn": "questlevel_6.tscn",
	"test_8.tscn": "questlevel_7.tscn",
	# Tutorial scenes: ไม่มี quest config — ปุ่ม Quest/Hint จะซ่อนอัตโนมัติ
	"tutorial_1.tscn": "",
}

@onready var help_button: Button = get_node("HelpButton")
@onready var quest_button: Button = get_node("QuestButton")
@onready var hint_button: Button = get_node("HintButton")
@onready var guide_window: Panel = get_node("GuideWindow")
@onready var close_button: Button = get_node("GuideWindow/CloseButton")
@onready var header_title: Label = get_node("GuideWindow/HeaderTitle")
@onready var header_subtitle: Label = get_node("GuideWindow/HeaderSubtitle")
@onready var badge_labels: Array[Label] = [
	get_node("GuideWindow/BadgeRow/BadgeBeginner"),
	get_node("GuideWindow/BadgeRow/BadgeLogic"),
	get_node("GuideWindow/BadgeRow/BadgeAutomation"),
	get_node("GuideWindow/BadgeRow/BadgeMiniC"),
]
@onready var manual_root: Control = get_node("GuideWindow/ManualRoot")
@onready var category_scroll: ScrollContainer = get_node("GuideWindow/ManualRoot/CategoryPanel/CategoryScroll")
@onready var category_buttons_box: VBoxContainer = get_node("GuideWindow/ManualRoot/CategoryPanel/CategoryScroll/CategoryButtons")
@onready var category_buttons: Array[Button] = [
	get_node("GuideWindow/ManualRoot/CategoryPanel/CategoryScroll/CategoryButtons/BasicButton"),
	get_node("GuideWindow/ManualRoot/CategoryPanel/CategoryScroll/CategoryButtons/ConveyorButton"),
	get_node("GuideWindow/ManualRoot/CategoryPanel/CategoryScroll/CategoryButtons/ArmButton"),
	get_node("GuideWindow/ManualRoot/CategoryPanel/CategoryScroll/CategoryButtons/SensorButton"),
	get_node("GuideWindow/ManualRoot/CategoryPanel/CategoryScroll/CategoryButtons/IfElseButton"),
	get_node("GuideWindow/ManualRoot/CategoryPanel/CategoryScroll/CategoryButtons/LoopButton"),
	get_node("GuideWindow/ManualRoot/CategoryPanel/CategoryScroll/CategoryButtons/ExampleButton"),
	get_node("GuideWindow/ManualRoot/CategoryPanel/CategoryScroll/CategoryButtons/ErrorButton"),
]
@onready var mission_body: Label = get_node("GuideWindow/ManualRoot/ContentPanel/ContentScroll/ContentVBox/MissionPanel/MissionBody")
@onready var section_title: Label = get_node("GuideWindow/ManualRoot/ContentPanel/ContentScroll/ContentVBox/SectionTitle")
@onready var section_body: Label = get_node("GuideWindow/ManualRoot/ContentPanel/ContentScroll/ContentVBox/SectionBody")
@onready var content_panel: Panel = get_node("GuideWindow/ManualRoot/ContentPanel")
@onready var content_scroll: ScrollContainer = get_node("GuideWindow/ManualRoot/ContentPanel/ContentScroll")
@onready var content_vbox: VBoxContainer = get_node("GuideWindow/ManualRoot/ContentPanel/ContentScroll/ContentVBox")
@onready var category_panel: Panel = get_node("GuideWindow/ManualRoot/CategoryPanel")
@onready var mission_panel: Panel = get_node("GuideWindow/ManualRoot/ContentPanel/ContentScroll/ContentVBox/MissionPanel")
@onready var command_cards: VBoxContainer = get_node("GuideWindow/ManualRoot/ContentPanel/ContentScroll/ContentVBox/CommandCards")
@onready var command_card_panels: Array[Panel] = [
	get_node("GuideWindow/ManualRoot/ContentPanel/ContentScroll/ContentVBox/CommandCards/Card1"),
	get_node("GuideWindow/ManualRoot/ContentPanel/ContentScroll/ContentVBox/CommandCards/Card2"),
	get_node("GuideWindow/ManualRoot/ContentPanel/ContentScroll/ContentVBox/CommandCards/Card3"),
]
@onready var card_icons: Array[Label] = [
	get_node("GuideWindow/ManualRoot/ContentPanel/ContentScroll/ContentVBox/CommandCards/Card1/Icon"),
	get_node("GuideWindow/ManualRoot/ContentPanel/ContentScroll/ContentVBox/CommandCards/Card2/Icon"),
	get_node("GuideWindow/ManualRoot/ContentPanel/ContentScroll/ContentVBox/CommandCards/Card3/Icon"),
]
@onready var card_titles: Array[Label] = [
	get_node("GuideWindow/ManualRoot/ContentPanel/ContentScroll/ContentVBox/CommandCards/Card1/Title"),
	get_node("GuideWindow/ManualRoot/ContentPanel/ContentScroll/ContentVBox/CommandCards/Card2/Title"),
	get_node("GuideWindow/ManualRoot/ContentPanel/ContentScroll/ContentVBox/CommandCards/Card3/Title"),
]
@onready var card_descs: Array[Label] = [
	get_node("GuideWindow/ManualRoot/ContentPanel/ContentScroll/ContentVBox/CommandCards/Card1/Desc"),
	get_node("GuideWindow/ManualRoot/ContentPanel/ContentScroll/ContentVBox/CommandCards/Card2/Desc"),
	get_node("GuideWindow/ManualRoot/ContentPanel/ContentScroll/ContentVBox/CommandCards/Card3/Desc"),
]
@onready var card_codes: Array[RichTextLabel] = [
	get_node("GuideWindow/ManualRoot/ContentPanel/ContentScroll/ContentVBox/CommandCards/Card1/Code"),
	get_node("GuideWindow/ManualRoot/ContentPanel/ContentScroll/ContentVBox/CommandCards/Card2/Code"),
	get_node("GuideWindow/ManualRoot/ContentPanel/ContentScroll/ContentVBox/CommandCards/Card3/Code"),
]
@onready var quick_example_panel: Panel = get_node("GuideWindow/ManualRoot/ContentPanel/ContentScroll/ContentVBox/QuickExamplePanel")
@onready var quick_example_code: RichTextLabel = get_node("GuideWindow/ManualRoot/ContentPanel/ContentScroll/ContentVBox/QuickExamplePanel/QuickExampleCode")
@onready var quick_example_desc: Label = get_node("GuideWindow/ManualRoot/ContentPanel/ContentScroll/ContentVBox/QuickExamplePanel/QuickExampleDesc")
@onready var quest_root: Control = get_node("GuideWindow/QuestRoot")
@onready var quest_panel: Panel = get_node("GuideWindow/QuestRoot/QuestPanel")
@onready var quest_goal: Label = get_node("GuideWindow/QuestRoot/QuestPanel/QuestGoal")
@onready var quest_checklist: Label = get_node("GuideWindow/QuestRoot/QuestPanel/QuestChecklist")
@onready var quest_concepts: Label = get_node("GuideWindow/QuestRoot/QuestPanel/QuestConcepts")
@onready var hint_window: Panel = get_node("HintWindow")
@onready var hint_title: Label = get_node("HintWindow/HintTitle")
@onready var hint_subtitle: Label = get_node("HintWindow/HintSubtitle")
@onready var hint_close_button: Button = get_node("HintWindow/CloseButton")
@onready var hint_scroll: ScrollContainer = get_node("HintWindow/HintScroll")
@onready var hint_label: Label = get_node("HintWindow/HintScroll/Label")
@onready var hint_prev_button: Button = get_node("HintWindow/PrevButton")
@onready var hint_next_button: Button = get_node("HintWindow/NextButton")

var _is_quest_scene: bool = false
var _selected_category: int = 0
var _hint_index: int = 0
var _tween: Tween
var _hint_tween: Tween

func _ready() -> void:
	_is_quest_scene = not _get_quest_config().is_empty()
	add_to_group("guide_overlay_ui")
	_style_static_ui()
	_refresh_top_tabs("guide")
	_connect_buttons()
	_apply_scene_mode()
	_refresh_manual_content()
	_refresh_quest_content()
	_refresh_hint_text()

func open_guide() -> void:
	_show_manual_root()
	_refresh_top_tabs("guide")
	_layout_guide_window("manual")
	_open_window(guide_window, true)
	close_hint_immediate()

func open_quest() -> void:
	if not _is_quest_scene:
		open_guide()
		return
	_show_quest_root()
	_refresh_quest_content()
	_refresh_top_tabs("quest")
	_layout_guide_window("quest")
	_open_window(guide_window, true)
	close_hint_immediate()

func close_guide() -> void:
	_close_window(guide_window, true)

func close_guide_immediate() -> void:
	_close_window_immediate(guide_window, true)

func open_hint() -> void:
	if not _is_quest_scene:
		return
	_hint_index = GameData.get_level_hint_index(_get_level_file_name())
	_refresh_hint_text()
	_refresh_top_tabs("hint")
	_layout_hint_window()
	_open_window(hint_window, false)
	close_guide_immediate()

func close_hint() -> void:
	_close_window(hint_window, false)

func close_hint_immediate() -> void:
	_close_window_immediate(hint_window, false)

func _apply_scene_mode() -> void:
	guide_window.visible = false
	hint_window.visible = false
	guide_window.modulate.a = 1.0
	hint_window.modulate.a = 1.0
	quest_button.visible = _is_quest_scene
	hint_button.visible = _is_quest_scene

func _connect_buttons() -> void:
	if not help_button.pressed.is_connected(open_guide):
		help_button.pressed.connect(open_guide)
	if not quest_button.pressed.is_connected(open_quest):
		quest_button.pressed.connect(open_quest)
	if not hint_button.pressed.is_connected(open_hint):
		hint_button.pressed.connect(open_hint)
	if not close_button.pressed.is_connected(close_guide):
		close_button.pressed.connect(close_guide)
	if not hint_close_button.pressed.is_connected(close_hint):
		hint_close_button.pressed.connect(close_hint)
	if not hint_prev_button.pressed.is_connected(_on_hint_prev_pressed):
		hint_prev_button.pressed.connect(_on_hint_prev_pressed)
	if not hint_next_button.pressed.is_connected(_on_hint_next_pressed):
		hint_next_button.pressed.connect(_on_hint_next_pressed)

	for idx in range(category_buttons.size()):
		var button: Button = category_buttons[idx]
		if not button.pressed.is_connected(_on_category_pressed.bind(idx)):
			button.pressed.connect(_on_category_pressed.bind(idx))

func _style_static_ui() -> void:
	_style_top_tab(help_button, true, Color8(238, 170, 62))
	_style_top_tab(quest_button, false, Color8(45, 110, 210))
	_style_top_tab(hint_button, false, Color8(237, 151, 40))

	_style_overlay_panel(guide_window, Color(0.075, 0.095, 0.12, 0.96), Color8(247, 169, 45))
	_style_overlay_panel(hint_window, Color(0.075, 0.095, 0.12, 0.96), Color8(247, 169, 45))

	header_title.add_theme_color_override("font_color", Color8(244, 247, 252))
	header_title.add_theme_font_size_override("font_size", 28)
	header_subtitle.add_theme_color_override("font_color", Color8(171, 198, 234))
	header_subtitle.add_theme_font_size_override("font_size", 16)

	for badge in badge_labels:
		badge.add_theme_color_override("font_color", Color8(18, 24, 34))
		badge.add_theme_font_size_override("font_size", 13)
		badge.add_theme_stylebox_override("normal", _make_style(Color8(92, 214, 169), 12, Color8(138, 243, 201), 1))

	_style_panel(get_node("GuideWindow/ManualRoot/CategoryPanel"), Color8(19, 28, 40), Color8(67, 98, 144))
	_style_panel(get_node("GuideWindow/ManualRoot/ContentPanel"), Color8(19, 28, 40), Color8(67, 98, 144))
	_style_panel(get_node("GuideWindow/ManualRoot/ContentPanel/ContentScroll/ContentVBox/MissionPanel"), Color8(24, 41, 63), Color8(78, 129, 194))
	_style_panel(get_node("GuideWindow/ManualRoot/ContentPanel/ContentScroll/ContentVBox/QuickExamplePanel"), Color8(11, 15, 24), Color8(71, 124, 201))
	_style_panel(get_node("GuideWindow/QuestRoot/QuestPanel"), Color8(19, 28, 40), Color8(67, 98, 144))

	var card_paths := [
		"GuideWindow/ManualRoot/ContentPanel/ContentScroll/ContentVBox/CommandCards/Card1",
		"GuideWindow/ManualRoot/ContentPanel/ContentScroll/ContentVBox/CommandCards/Card2",
		"GuideWindow/ManualRoot/ContentPanel/ContentScroll/ContentVBox/CommandCards/Card3",
	]
	for path in card_paths:
		_style_panel(get_node(path), Color8(22, 33, 48), Color8(77, 123, 196))

	var title_labels := [
		get_node("GuideWindow/ManualRoot/CategoryPanel/CategoryTitle") as Label,
		get_node("GuideWindow/ManualRoot/ContentPanel/ContentScroll/ContentVBox/MissionPanel/MissionTitle") as Label,
		get_node("GuideWindow/ManualRoot/ContentPanel/ContentScroll/ContentVBox/QuickExamplePanel/QuickExampleTitle") as Label,
		get_node("GuideWindow/QuestRoot/QuestPanel/QuestTitle") as Label,
	]
	for label in title_labels:
		label.add_theme_color_override("font_color", Color8(255, 198, 91))
		label.add_theme_font_size_override("font_size", 20)

	var body_labels := [
		get_node("GuideWindow/ManualRoot/CategoryPanel/CategoryHint") as Label,
		mission_body,
		section_title,
		section_body,
		quick_example_desc,
		quest_goal,
		quest_checklist,
		quest_concepts,
	]
	for label in body_labels:
		label.add_theme_color_override("font_color", Color8(229, 235, 245))
		label.add_theme_font_size_override("font_size", 16)

	section_title.add_theme_color_override("font_color", Color8(245, 248, 252))
	section_title.add_theme_font_size_override("font_size", 24)
	section_body.add_theme_color_override("font_color", Color8(178, 199, 229))

	for idx in range(card_icons.size()):
		card_icons[idx].add_theme_color_override("font_color", Color8(255, 198, 91))
		card_icons[idx].add_theme_font_size_override("font_size", 20)
		card_titles[idx].add_theme_color_override("font_color", Color8(245, 248, 252))
		card_titles[idx].add_theme_font_size_override("font_size", 18)
		card_descs[idx].add_theme_color_override("font_color", Color8(179, 199, 229))
		card_descs[idx].add_theme_font_size_override("font_size", 15)
		card_codes[idx].add_theme_color_override("default_color", Color8(140, 232, 210))
		card_codes[idx].add_theme_font_size_override("normal_font_size", 15)
		card_codes[idx].add_theme_stylebox_override("normal", _make_style(Color8(9, 13, 20), 10, Color8(51, 86, 138), 1))

	quick_example_code.add_theme_color_override("default_color", Color8(140, 232, 210))
	quick_example_code.add_theme_font_size_override("normal_font_size", 16)
	quick_example_code.add_theme_stylebox_override("normal", _make_style(Color8(9, 13, 20), 12, Color8(51, 86, 138), 1))

	_style_close_button(close_button)
	_style_close_button(hint_close_button)
	_style_hint_nav_button(hint_prev_button)
	_style_hint_nav_button(hint_next_button)
	hint_label.add_theme_color_override("font_color", Color8(238, 242, 248))
	hint_label.add_theme_font_size_override("font_size", 18)
	hint_label.add_theme_constant_override("line_spacing", 5)

	for idx in range(category_buttons.size()):
		_style_category_button(category_buttons[idx], idx == _selected_category)

func _style_top_tab(button: Button, is_active: bool, active_color: Color) -> void:
	button.add_theme_color_override("font_color", Color8(248, 248, 250))
	button.add_theme_font_size_override("font_size", 18)
	var normal_color := Color8(32, 41, 56) if not is_active else active_color
	var border := Color8(86, 118, 172) if not is_active else Color8(255, 223, 141)
	button.add_theme_stylebox_override("normal", _make_style(normal_color, 18, border, 3))
	button.add_theme_stylebox_override("hover", _make_style(active_color, 18, Color8(255, 223, 141), 3))
	button.add_theme_stylebox_override("pressed", _make_style(active_color, 18, Color8(255, 223, 141), 3))

func _refresh_top_tabs(active_tab: String) -> void:
	_style_top_tab(help_button, active_tab == "guide", Color8(238, 170, 62))
	_style_top_tab(quest_button, active_tab == "quest", Color8(45, 110, 210))
	_style_top_tab(hint_button, active_tab == "hint", Color8(237, 151, 40))

func _style_overlay_panel(panel: Panel, bg: Color, border: Color) -> void:
	panel.add_theme_stylebox_override("panel", _make_style(bg, 24, border, 4))

func _style_panel(panel: Control, bg: Color, border: Color) -> void:
	panel.add_theme_stylebox_override("panel", _make_style(bg, 18, border, 2))

func _style_close_button(button: Button) -> void:
	button.add_theme_color_override("font_color", Color8(255, 247, 237))
	button.add_theme_font_size_override("font_size", 20)
	button.add_theme_stylebox_override("normal", _make_style(Color8(168, 49, 49), 16, Color8(255, 214, 126), 2))
	button.add_theme_stylebox_override("hover", _make_style(Color8(206, 61, 61), 16, Color8(255, 224, 154), 2))
	button.add_theme_stylebox_override("pressed", _make_style(Color8(133, 38, 38), 16, Color8(255, 214, 126), 2))

func _style_category_button(button: Button, is_active: bool) -> void:
	button.add_theme_color_override("font_color", Color8(17, 22, 31) if is_active else Color8(240, 244, 250))
	button.add_theme_font_size_override("font_size", 16)
	var bg := Color8(237, 171, 65) if is_active else Color8(31, 43, 62)
	var border := Color8(255, 223, 141) if is_active else Color8(80, 118, 176)
	button.add_theme_stylebox_override("normal", _make_style(bg, 14, border, 2))
	button.add_theme_stylebox_override("hover", _make_style(Color8(65, 121, 214), 14, Color8(152, 208, 255), 2))
	button.add_theme_stylebox_override("pressed", _make_style(Color8(65, 121, 214), 14, Color8(152, 208, 255), 2))

func _style_hint_nav_button(button: Button) -> void:
	button.add_theme_color_override("font_color", Color8(245, 248, 252))
	button.add_theme_font_size_override("font_size", 16)
	button.add_theme_stylebox_override("normal", _make_style(Color8(32, 41, 56), 14, Color8(86, 118, 172), 2))
	button.add_theme_stylebox_override("hover", _make_style(Color8(237, 171, 65), 14, Color8(255, 223, 141), 2))
	button.add_theme_stylebox_override("pressed", _make_style(Color8(237, 171, 65), 14, Color8(255, 223, 141), 2))

func _refresh_manual_content() -> void:
	var category: Dictionary = GUIDE_CATEGORIES[_selected_category]
	mission_body.text = str(category.get("mission", ""))
	section_title.text = str(category.get("title", "คู่มือ Mini-C"))
	section_body.text = str(category.get("summary", ""))

	var cards: Array = category.get("cards", [])
	for idx in range(card_titles.size()):
		var card_data: Dictionary = cards[idx] if idx < cards.size() else {}
		card_icons[idx].text = str(card_data.get("icon", "--"))
		card_titles[idx].text = str(card_data.get("title", ""))
		card_descs[idx].text = str(card_data.get("desc", ""))
		card_codes[idx].text = "[code]%s[/code]" % str(card_data.get("code", ""))

	quick_example_code.text = "[code]%s[/code]" % str(category.get("quick_code", ""))
	quick_example_desc.text = str(category.get("quick_desc", ""))

	for idx in range(category_buttons.size()):
		_style_category_button(category_buttons[idx], idx == _selected_category)

func _refresh_quest_content() -> void:
	var config: Dictionary = _get_quest_config()
	if config.is_empty():
		quest_goal.text = "เป้าหมาย: ใช้คู่มือ Mini-C เพื่อเรียนรู้คำสั่งก่อนเริ่มภารกิจ"
		quest_checklist.text = "ขั้นตอนแนะนำ:\n1. เปิดคู่มือ\n2. ดูตัวอย่างโค้ด\n3. เขียนคำสั่งตามลำดับ"
		quest_concepts.text = "แนวคิดที่ต้องใช้:\n- start()\n- wait_until()\n- if / else"
		return

	quest_goal.text = "เป้าหมาย:\n%s" % str(config.get("goal", ""))

	var step_lines: Array[String] = ["ขั้นตอนแนะนำ:"]
	for idx in range((config.get("steps", []) as Array).size()):
		step_lines.append("%d. %s" % [idx + 1, str(config["steps"][idx])])
	quest_checklist.text = "\n".join(step_lines)

	var concept_lines: Array[String] = ["แนวคิดที่ต้องใช้:"]
	for concept in config.get("concepts", []):
		concept_lines.append("- %s" % str(concept))
	quest_concepts.text = "\n".join(concept_lines)

func _refresh_hint_text() -> void:
	var config: Dictionary = _get_quest_config()
	var hint_pages: Array[String] = _build_hint_pages(config)
	if hint_pages.is_empty():
		hint_label.text = "ยังไม่มีคำใบ้สำหรับด่านนี้"
		_update_hint_nav_buttons(0)
		return

	var level_id: String = _get_level_file_name()
	_hint_index = GameData.set_level_hint_index(level_id, _hint_index, hint_pages.size())
	hint_label.text = "%s\n\nคำใบ้ %d/%d\n\n%s" % [
		str(config.get("title", "คำใบ้")),
		_hint_index + 1,
		hint_pages.size(),
		hint_pages[_hint_index],
	]
	_update_hint_nav_buttons(hint_pages.size())

func _show_manual_root() -> void:
	header_title.text = "คู่มือ Mini-C"
	header_subtitle.text = "คำสั่งพื้นฐานสำหรับควบคุมคลังสินค้าอัตโนมัติ"
	manual_root.visible = true
	quest_root.visible = false

func _show_quest_root() -> void:
	var config: Dictionary = _get_quest_config()
	header_title.text = "ภารกิจปัจจุบัน"
	header_subtitle.text = str(config.get("title", "เป้าหมายของด่านนี้"))
	manual_root.visible = false
	quest_root.visible = true

func _layout_guide_window(mode: String) -> void:
	var viewport_size: Vector2 = get_viewport().get_visible_rect().size
	var margin: Vector2 = Vector2(72, 120)
	var target_size: Vector2
	if mode == "quest":
		target_size = Vector2(
			minf(980.0, viewport_size.x - margin.x * 2.0),
			minf(480.0, viewport_size.y - margin.y * 2.0)
		)
	else:
		target_size = Vector2(
			minf(1320.0, viewport_size.x - 72.0),
			minf(740.0, viewport_size.y - 128.0)
		)

	guide_window.size = target_size
	guide_window.position = Vector2(
		(viewport_size.x - target_size.x) * 0.5,
		clampf((viewport_size.y - target_size.y) * 0.5 + 82.0, 144.0, viewport_size.y - target_size.y - 24.0)
	)
	close_button.position = Vector2(target_size.x - 100.0, 28.0)

	if mode == "manual":
		manual_root.position = Vector2(34, 196)
		manual_root.size = Vector2(target_size.x - 68.0, target_size.y - 238.0)
		category_panel.size = Vector2(282, manual_root.size.y)
		category_scroll.position = Vector2(20.0, 138.0)
		category_scroll.size = Vector2(242.0, category_panel.size.y - 170.0)
		category_buttons_box.custom_minimum_size = Vector2(230.0, 420.0)
		content_panel.position = Vector2(304, 0)
		content_panel.size = Vector2(manual_root.size.x - 304.0, manual_root.size.y)
		content_scroll.position = Vector2(24, 24)
		content_scroll.size = Vector2(content_panel.size.x - 50.0, content_panel.size.y - 48.0)
		content_vbox.custom_minimum_size = Vector2(content_scroll.size.x - 30.0, 980)
		_layout_manual_content_boxes(content_scroll.size.x - 26.0)
	else:
		quest_root.position = Vector2(34, 196)
		quest_root.size = Vector2(target_size.x - 68.0, target_size.y - 238.0)
		quest_panel.size = quest_root.size
		quest_goal.size = Vector2(quest_panel.size.x - 48.0, 52)
		quest_checklist.size = Vector2((quest_panel.size.x - 84.0) * 0.5, quest_panel.size.y - 160.0)
		quest_concepts.position = Vector2(quest_checklist.position.x + quest_checklist.size.x + 36.0, 136.0)
		quest_concepts.size = Vector2(quest_panel.size.x - quest_concepts.position.x - 24.0, quest_panel.size.y - 160.0)

func _layout_manual_content_boxes(content_width: float) -> void:
	var block_width: float = content_width - 28.0
	var text_width: float = block_width - 114.0
	mission_panel.custom_minimum_size = Vector2(block_width, 118)
	mission_panel.size = Vector2(block_width, 118)
	mission_body.position = Vector2(18, 50)
	mission_body.size = Vector2(block_width - 36.0, 50.0)
	section_title.size.x = block_width
	section_body.size = Vector2(block_width, 48.0)
	command_cards.custom_minimum_size = Vector2(block_width, command_cards.custom_minimum_size.y)

	for idx in range(command_card_panels.size()):
		var card_panel: Panel = command_card_panels[idx]
		card_panel.custom_minimum_size = Vector2(block_width, 188)
		card_panel.size = Vector2(block_width, 188)
		card_icons[idx].position = Vector2(20.0, 18.0)
		card_icons[idx].size = Vector2(42.0, 28.0)
		card_titles[idx].position.x = 78.0
		card_titles[idx].position.y = 16.0
		card_titles[idx].size = Vector2(text_width, 30.0)
		card_descs[idx].position.x = 78.0
		card_descs[idx].position.y = 54.0
		card_descs[idx].size = Vector2(text_width, 42.0)
		card_codes[idx].position.x = 78.0
		card_codes[idx].position.y = 108.0
		card_codes[idx].size = Vector2(text_width, 58.0)

	quick_example_panel.custom_minimum_size = Vector2(block_width, 260)
	quick_example_panel.size = Vector2(block_width, 260)
	quick_example_code.position = Vector2(18.0, 56.0)
	quick_example_code.size = Vector2(minf(520.0, block_width * 0.52), 182.0)
	quick_example_desc.position.x = quick_example_code.position.x + quick_example_code.size.x + 24.0
	quick_example_desc.position.y = 56.0
	quick_example_desc.size = Vector2(block_width - quick_example_desc.position.x - 18.0, 176.0)

func _layout_hint_window() -> void:
	var viewport_size: Vector2 = get_viewport().get_visible_rect().size
	var margin: Vector2 = Vector2(76, 126)
	var target_size := Vector2(
		minf(940.0, viewport_size.x - margin.x * 2.0),
		minf(408.0, viewport_size.y - margin.y * 2.0 - 16.0)
	)

	hint_window.size = target_size
	hint_window.position = Vector2(
		(viewport_size.x - target_size.x) * 0.5,
		clampf((viewport_size.y - target_size.y) * 0.5 + 84.0, 146.0, viewport_size.y - target_size.y - 20.0)
	)
	hint_close_button.position = Vector2(target_size.x - 100.0, 28.0)
	hint_scroll.position = Vector2(34, 146)
	hint_scroll.size = Vector2(target_size.x - 98.0, target_size.y - 228.0)
	hint_label.custom_minimum_size = Vector2(hint_scroll.size.x - 36.0, maxf(220.0, hint_scroll.size.y - 10.0))
	hint_prev_button.position = Vector2(target_size.x - 272.0, target_size.y - 62.0)
	hint_next_button.position = Vector2(target_size.x - 136.0, target_size.y - 62.0)

func _open_window(target: Control, is_guide: bool) -> void:
	_close_other_overlays()
	if is_guide:
		_kill_tween()
	else:
		_kill_hint_tween()
	target.visible = true
	target.modulate.a = 0.0
	var tween := create_tween()
	tween.tween_property(target, "modulate:a", 1.0, 0.18)
	if is_guide:
		_tween = tween
	else:
		_hint_tween = tween

func _close_window(target: Control, is_guide: bool) -> void:
	if is_guide:
		_kill_tween()
	else:
		_kill_hint_tween()
	var tween := create_tween()
	tween.tween_property(target, "modulate:a", 0.0, 0.16)
	tween.finished.connect(func():
		target.visible = false
		target.modulate.a = 1.0
	)
	if is_guide:
		_tween = tween
	else:
		_hint_tween = tween

func _close_window_immediate(target: Control, is_guide: bool) -> void:
	if is_guide:
		_kill_tween()
	else:
		_kill_hint_tween()
	target.visible = false
	target.modulate.a = 1.0

func _on_category_pressed(index: int) -> void:
	_selected_category = clampi(index, 0, GUIDE_CATEGORIES.size() - 1)
	_refresh_manual_content()

func _on_hint_prev_pressed() -> void:
	_hint_index -= 1
	_refresh_hint_text()

func _on_hint_next_pressed() -> void:
	_hint_index += 1
	_refresh_hint_text()

func _update_hint_nav_buttons(page_count: int) -> void:
	hint_prev_button.disabled = page_count <= 0 or _hint_index <= 0
	hint_next_button.disabled = page_count <= 0 or _hint_index >= page_count - 1

func _build_hint_pages(config: Dictionary) -> Array[String]:
	var pages: Array[String] = []
	var steps: Array = config.get("steps", [])
	if not steps.is_empty():
		var step_lines: Array[String] = ["สิ่งที่ต้องทำ:"]
		for idx in range(steps.size()):
			step_lines.append("%d. %s" % [idx + 1, str(steps[idx])])
		pages.append("\n".join(step_lines))

	for hint in config.get("hints", []):
		pages.append(str(hint))

	return pages

func _get_quest_config() -> Dictionary:
	var file_name: String = _get_level_file_name()
	if QUEST_SCENE_ALIASES.has(file_name):
		file_name = str(QUEST_SCENE_ALIASES[file_name])
	if QUEST_TEXT.has(file_name):
		return QUEST_TEXT[file_name]
	return {}

func _get_level_file_name() -> String:
	var main_scene := get_tree().current_scene
	if main_scene != null and not main_scene.scene_file_path.is_empty():
		return main_scene.scene_file_path.get_file()
	return scene_file_path.get_file()

func _make_style(bg: Color, radius: int, border: Color = Color.TRANSPARENT, border_width: int = 0) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = bg
	style.corner_radius_top_left = radius
	style.corner_radius_top_right = radius
	style.corner_radius_bottom_left = radius
	style.corner_radius_bottom_right = radius
	style.border_color = border
	style.border_width_left = border_width
	style.border_width_top = border_width
	style.border_width_right = border_width
	style.border_width_bottom = border_width
	style.shadow_color = Color(0, 0, 0, 0.18)
	style.shadow_size = 8
	style.content_margin_left = 12
	style.content_margin_top = 8
	style.content_margin_right = 12
	style.content_margin_bottom = 8
	return style

func _kill_tween() -> void:
	if _tween != null and _tween.is_valid():
		_tween.kill()
	_tween = null

func _kill_hint_tween() -> void:
	if _hint_tween != null and _hint_tween.is_valid():
		_hint_tween.kill()
	_hint_tween = null

func _close_other_overlays() -> void:
	for overlay in get_tree().get_nodes_in_group("guide_overlay_ui"):
		if overlay == self:
			continue
		if overlay.has_method("close_guide_immediate"):
			overlay.close_guide_immediate()
		if overlay.has_method("close_hint_immediate"):
			overlay.close_hint_immediate()
