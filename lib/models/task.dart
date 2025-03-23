/*class Task {
  String title;            // ชื่องาน
  String description;      // รายละเอียดงาน
  DateTime dueDate;       // วันที่กำหนดส่ง
  bool isCompleted;        // สถานะการเสร็จสิ้นงาน
  int progress;            // ความคืบหน้า (0-100)
  String? referenceId;     // รหัสอ้างอิง

  static const collectionName = 'tasks';
  static const colTitle = 'title';
  static const colDescription = 'description';
  static const colDueDate = 'dueDate';
  static const colIsCompleted = 'isCompleted';
  static const colProgress = 'progress';

  Task({
    required this.title,
    required this.description,
    required this.dueDate,
    this.isCompleted = false,
    this.progress = 0,
    this.referenceId,
  });

  // เปลี่ยนชื่อฟังก์ชันจาก toJson เป็น toMap เพื่อความชัดเจน
  Map<String, dynamic> toMap() {
    return {
      colTitle: title,
      colDescription: description,
      colDueDate: dueDate.toIso8601String(), // แปลง DateTime เป็น String
      colIsCompleted: isCompleted,
      colProgress: progress,
    };
  }

  // แก้ชื่อฟังก์ชันเป็น fromMap และไม่ต้องการพารามิเตอร์ id
  static Task fromMap(Map<String, dynamic> json, String id) {
    return Task(
      title: json[colTitle],
      description: json[colDescription],
      dueDate: DateTime.parse(json[colDueDate]), // แปลง String กลับเป็น DateTime
      isCompleted: json[colIsCompleted] ?? false,
      progress: json[colProgress] ?? 0,
      referenceId: id, // รับรหัสอ้างอิงจาก Firestore
    );
  }
}
*/