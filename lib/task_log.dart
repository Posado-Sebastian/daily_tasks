class TaskLog {
  final int? id;
  final int taskId;
  final DateTime date;
  final String status;

  TaskLog({
    this.id,
    required this.taskId,
    required this.date,
    required this.status,
  });

  Map<String, Object?> toMap() {
    return {
      if (id != null) 'id': id,
      'taskId': taskId,
      'date': DateTime(date.year, date.month, date.day).toIso8601String(),
      'status': status,
    };
  }

  factory TaskLog.fromMap(Map<String, Object?> map) {
    return TaskLog(
      id: map['id'] as int?,
      taskId: map['taskId'] as int,
      date: DateTime.parse(map['date'] as String),
      status: map['status'] as String,
    );
  }
}