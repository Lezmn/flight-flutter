// ค่า key อ่านมาจาก env.json ตอน build/run:
//   flutter run --dart-define-from-file=env.json
class Env {
  static const aviationstackApiKey = String.fromEnvironment('AVIATIONSTACK_API_KEY');
}
