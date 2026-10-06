# Flight Booking App ✈️

แอปจองตั๋วเครื่องบินที่พัฒนาด้วย Flutter + Firebase
ค้นหาเที่ยวบินจริงผ่าน [AviationStack API](https://aviationstack.com/)

## ฟีเจอร์

- สมัครสมาชิก / เข้าสู่ระบบด้วย Firebase Authentication
- ค้นหาเที่ยวบินตามสนามบินต้นทาง–ปลายทาง (AviationStack)
- จองตั๋วและดูรายการจองของฉัน พร้อม QR code
- โปรโมชั่นและโค้ดส่วนลด
- แนะนำสถานที่ท่องเที่ยว
- จัดการข้อมูลบัญชีผู้ใช้

ข้อมูลเก็บใน Cloud Firestore: `users`, `bookings`, `promotions`

## การติดตั้ง

### 1. สิ่งที่ต้องมี

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (Dart 3.3 ขึ้นไป)
- API key ของ [AviationStack](https://aviationstack.com/signup/free) (มีแพ็กเกจฟรี)

### 2. ติดตั้ง dependencies

```bash
flutter pub get
```

### 3. ตั้งค่า API key

API key **ไม่ได้อยู่ในโค้ด** ต้องสร้างไฟล์ `env.json` เองที่ root ของโปรเจกต์
(ไฟล์นี้อยู่ใน `.gitignore` จะไม่ถูก commit)

```bash
cp env.example.json env.json
```

แล้วแก้ค่าใน `env.json`:

```json
{
  "AVIATIONSTACK_API_KEY": "ใส่_key_ของคุณที่นี่"
}
```

> ⚠️ ห้าม commit `env.json` หรือใส่ key ลงในโค้ดโดยตรง

### 4. รันแอป

ต้องส่ง `--dart-define-from-file=env.json` ทุกครั้งที่รันหรือ build

```bash
flutter run --dart-define-from-file=env.json
```

Build:

```bash
flutter build apk --dart-define-from-file=env.json
```

ถ้าลืมใส่ flag นี้ หน้าค้นหาเที่ยวบินจะแจ้ง error `Missing AVIATIONSTACK_API_KEY`

## โครงสร้างโปรเจกต์

```
lib/
├── main.dart                 # จุดเริ่มแอป + AuthGate
├── env.dart                  # อ่าน API key จาก --dart-define
├── apiservices.dart          # เรียก AviationStack API
├── firebase_options.dart     # ค่า config Firebase (สร้างโดย FlutterFire CLI)
├── sign_in_page.dart         # เข้าสู่ระบบ
├── register_page.dart        # สมัครสมาชิก
├── home_page.dart            # หน้าหลัก + เมนูบัญชี
├── home_screen.dart          # โปรโมชั่น / สถานที่ท่องเที่ยว
├── flight_search_page.dart   # ค้นหาเที่ยวบิน
├── flight_ticket.dart        # รายละเอียด / จองตั๋ว
├── my_bookings_page.dart     # รายการจองของฉัน
├── qr.dart                   # QR code ตั๋ว
└── ...
```

## ทีมพัฒนา

| ชื่อ | หน้าที่ |
|---|---|
| ธนบดี ประดับคำ | ผู้พัฒนาแอปพลิเคชัน |
| คุณาวุฒิ ดอกบัว | ฝ่ายออกแบบ UI/UX |
| นนทกร | ฝ่ายออกแบบ UI/UX |
