class Task {
  final int? id;  
  final String title;
  final bool isCompleted;
  final List<String> days;

  Task({
    this.id,
    required this.title,
    required this.isCompleted,
    required this.days,
  });

  Map<String, Object?> toMap() {
    return {
      if (id != null) 'id': id,
      'title': title,
      'isCompleted': isCompleted ? 1 : 0,
      'days': days.join(','),
    };
  }

  factory Task.fromMap(Map<String, Object?> map) {
    return Task(
      id: map['id'] as int?,
      title: map['title'] as String,
      isCompleted: map['isCompleted'] == 1,
      days: map['days'] != null && (map['days'] as String).isNotEmpty
          ? (map['days'] as String).split(',')
          : [],
    );
  }
}