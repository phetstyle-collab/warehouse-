# Mini-C Syntax (Project Version)

เอกสารนี้อ้างอิงจาก parser/runtime ปัจจุบันของโปรเจกต์ (`mini_c_parser.gd`, `mini_c_runtime.gd`, `factory_controller.gd`)

## 1. กฎพื้นฐาน

- คำสั่งส่วนใหญ่ต้องลงท้ายด้วย `;`
- ภาษานี้ไม่ case-sensitive สำหรับ keyword/action หลายตัว (เช่น `while`, `WHILE`)
- คอมเมนต์ใช้ `#`
- บล็อกใช้ `{ ... }`
- parser จัด format วงเล็บปีกกาให้อัตโนมัติระดับหนึ่ง (เขียน inline block ได้)

ตัวอย่าง:

```mini-c
# comment
start(spawner);
while true {
    stop(spawner);
}
```

## 2. โครงสร้างควบคุม

## `IF`

```mini-c
if (weight > 5) {
    stop(spawner);
}
```

มี `ELSE` ได้:

```mini-c
if (weight > 5) {
    stop(spawner);
} else {
    start(spawner);
}
```

## `WHILE`

```mini-c
while true {
    start(conveyor);
}
```

## `REPEAT`

```mini-c
repeat 5 {
    rotate(arm(-90));
}
```

หรือ `repeat(5) { ... }`

## `BREAK`

```mini-c
break;
```

(`break` ไม่มี `;` ก็ parse ได้ แต่แนะนำให้ใส่)

## 3. WAIT UNTIL

### แบบบรรทัดเดียว

```mini-c
wait until (action(done));
wait until (weight(has_value));
wait until (weight > 5);
```

### แบบบล็อก

```mini-c
wait until (weight(has_value)) {
    if (weight > 5) {
        stop(spawner);
    }
}
```

หมายเหตุ: บล็อกของ `wait until` จะถูกตีความเป็น
1) รอให้เงื่อนไขผ่าน  
2) แล้วค่อยรันคำสั่งในบล็อกต่อ

## 4. Function และ Call

## ประกาศฟังก์ชัน

```mini-c
func pick_heavy {
    stop(spawner);
    pick(box);
}
```

รองรับพารามิเตอร์:

```mini-c
func move_arm(angle_pick, angle_drop) {
    rotate(arm(angle_pick));
    wait until (action(done));
    rotate(arm(angle_drop));
}
```

## เรียกใช้

```mini-c
call pick_heavy;
```

เรียกพร้อม argument:

```mini-c
call move_arm(-90, 180);
```

หมายเหตุ:
- parameter ใช้ได้ดีสำหรับค่าตัวเลข/นิพจน์ (เช่นมุมหมุน, ค่าที่ใช้เปรียบเทียบ, conveyor index)
- parameter ใช้กับ target ของ `start/stop` ได้ในฟังก์ชัน เช่น `start(sp); stop(cv);` เมื่อส่ง `spawner/conveyor` เข้ามา

## 5. ตัวแปร

มี 2 แบบหลัก

## 5.1 Numeric variable (ต้องมีชนิด)

```mini-c
var int count = 0;
var float ratio = 1.5;
count += 1;
count = count + 2;
count %= 3;
count = idiv(count, 2);
```

รองรับ `+= -= *= /= %= //=`, `++ --`, assignment ปกติ

หมายเหตุคณิตศาสตร์:
- หารเอาเศษใช้ `%` เช่น `count % 2`
- หารไม่เอาเศษใช้ `idiv(a, b)` หรือ `//=`
  - `idiv(7, 3)` ได้ `2`
  - `x //= 3` เทียบเท่า `x = idiv(x, 3)`

## 5.2 Action alias

```mini-c
var quick_stop = stop(spawner);
quick_stop;
```

## 6. เงื่อนไข (Condition)

รองรับ:

- `TRUE`, `FALSE`
- เปรียบเทียบตัวเลข/ค่าเซนเซอร์: `== != > < >= <=`
- semantic check: `HAS_VALUE`, `NOT_DETECTED`, `IS`
- logical operator: `&&`, `||`

ตัวอย่าง:

```mini-c
if (weight > 5 && weight < 10) {
    pick(box);
}

if (color == red || weight >= 8) {
    stop(conveyor);
}
```

## 7. Action Commands

คำสั่งจะถูก normalize ไปเป็น opcode ภายใน เช่น `START_SPAWNER`, `ROTATE_ARM -90`

## 7.1 Spawner/Conveyor

แนะนำ:

```mini-c
start(spawner);
stop(spawner);
start(conveyor);
stop(conveyor);
```

รองรับ conveyor index:

```mini-c
start(conveyor, 2);
stop(conveyor, 2);
```

## 7.2 Arm

รูปแบบที่แนะนำ (ตามที่โปรเจกต์ใช้ล่าสุด):

```mini-c
rotate(arm(-90));
rotate(arm(180));
```

หลายแขน (เช่นฉาก `testtrytworobot`) รองรับ:

```mini-c
rotate(arm_1(-90));
rotate(arm_2(90));
```

สรุปที่รองรับ:
- `rotate(arm(<angle>));` -> ใช้แขนหลัก (default)
- `rotate(<arm_label>(<angle>));` -> เลือกแขนตาม label เช่น `arm_1`, `arm_2`

## 7.3 Pick/Drop

```mini-c
pick(box);
drop(box);
```

หลายแขนรองรับ:

```mini-c
pick(arm_1, box);
drop(arm_1, box);
pick(arm_2, box);
drop(arm_2, box);
```

## 7.4 Diverter

```mini-c
set(diverter, left);
set(diverter, right);
set(diverter, open);
set(diverter, close);
```

หรือ opcode ตรง:

```mini-c
DIVERTER_LEFT();
DIVERTER_RIGHT();
DIVERTER_OPEN();
DIVERTER_CLOSE();
```


```

## 9. Error ที่เจอบ่อย

- ลืม `;` ท้าย action/call/var/assignment
- ลืม `{` หรือ `}`
- `rotate` เขียนรูปแบบไม่ถูก
- ใช้ชื่อที่เป็น keyword/action opcode ไปตั้งเป็นชื่อฟังก์ชันหรือตัวแปร
- `var` แบบเลขลืมระบุชนิด `int`/`float`
