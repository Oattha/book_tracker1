class Task2 {
  String title;
  String description;
  DateTime dueDate;
  bool isCompleted;
  int progress;
  String? referenceId;
  String? imageUrl;

  static const collectionName = 'tasks';

  Task2({
    required this.title,
    required this.description,
    required this.dueDate,
    this.isCompleted = false,
    this.progress = 0,
    this.referenceId,
    this.imageUrl,
  });

  // แปลงข้อมูลให้เก็บใน Firestore
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'dueDate': dueDate.toIso8601String(),
      'isCompleted': isCompleted,
      'progress': progress,
      'imageUrl': imageUrl,
    };
  }

  // แปลงข้อมูลจาก Firestore
  static Task2 fromMap(Map<String, dynamic> json, String id) {
    return Task2(
      title: json['title'],
      description: json['description'],
      dueDate: DateTime.parse(json['dueDate']),
      isCompleted: json['isCompleted'] ?? false,
      progress: json['progress'] ?? 0,
      referenceId: id,
      imageUrl: json['imageUrl'],
    );
  }
}
