class Task {
  String title;
  String description;
  DateTime dueDate;
  int progress;

  static const collectionName = 'tasks';

  Task({
    required this.title,
    required this.description,
    required this.dueDate,
    required this.progress,
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'dueDate': dueDate.toIso8601String(),
      'progress': progress,
    };
  }
}
