class Task {
  final int? id;  
  final String title;
  final List<String> days;
  final DateTime? startDate;
  final DateTime? endDate;

  Task({
    this.id,
    required this.title,
    required this.days,
    this.startDate,
    this.endDate,
  });

  Map<String, Object?> toMap() {
    return {
      if (id != null) 'id': id,
      'title': title,
      'days': days.join(','),
      'startDate': startDate?.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
    };
  }

  factory Task.fromMap(Map<String, Object?> map) {
    return Task(
      id: map['id'] as int?,
      title: map['title'] as String,
      days: map['days'] == null || (map['days'] as String).isEmpty
          ? []
          : (map['days'] as String).split(','),
      startDate: map['startDate'] == null
          ? null
          : DateTime.parse(map['startDate'] as String),
      endDate: map['endDate'] == null
          ? null
          : DateTime.parse(map['endDate'] as String),
    );
  }
}