class Task {
  final int? id;  
  final String title;
  final List<String> days;
  final bool isActive;

  Task({
    this.id,
    required this.title,
    required this.days,
    this.isActive = true,
  });

  Map<String, Object?> toMap() {
    return {
      if (id != null) 'id': id,
      'title': title,
      'days': days.join(','),
      'isActive': isActive ? 1 : 0,
    };
  }

  factory Task.fromMap(Map<String, Object?> map) {
    return Task(
      id: map['id'] as int?,
      title: map['title'] as String,
      days: map['days'] == null || (map['days'] as String).isEmpty
          ? []
          : (map['days'] as String).split(','),
      isActive: map['isActive'] == 1,
    );
  }
}