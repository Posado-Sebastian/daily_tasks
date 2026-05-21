class Task {
  final int? id;  
  final String title;
  final bool isCompleted;
  final DateTime date;

  Task({
    this.id,
    required this.title,
    required this.isCompleted,
    required this.date,
  });
  Map<String, Object?> toMap() {
    return {
      if (id != null) 'id': id,
      'title': title,
      'isCompleted': isCompleted ? 1 : 0, // Convertimos bool a 1 o 0
      'date': date.toIso8601String(), // Convertimos DateTime a Texto
    };
  }

  factory Task.fromMap(Map<String, Object?> map) {
    return Task(
      id: map['id'] as int?,
      title: map['title'] as String,
      isCompleted: map['isCompleted'] == 1, // Si es 1 es true, si no false
      date: DateTime.parse(map['date'] as String), // Convertimos Texto a DateTime
    );
  }
}