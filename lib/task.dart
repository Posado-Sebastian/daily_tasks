class Task {
  final int? id;  
  final String title;
  final List<String> days;
  final DateTime? specificDate;
  final bool isActive;

  Task({
    this.id,
    required this.title,
    required this.days,
    this.specificDate,
    this.isActive = true,
  });

  static DateTime? normalizeDate(DateTime? date) {
    if (date == null) {
      return null;
    }

    return DateTime(date.year, date.month, date.day);
  }

  static String? _serializeDate(DateTime? date) {
    final normalizedDate = normalizeDate(date);
    if (normalizedDate == null) {
      return null;
    }

    final month = normalizedDate.month.toString().padLeft(2, '0');
    final day = normalizedDate.day.toString().padLeft(2, '0');
    return '${normalizedDate.year}-$month-$day';
  }

  static DateTime? _deserializeDate(Object? value) {
    if (value == null) {
      return null;
    }

    return normalizeDate(DateTime.tryParse(value as String));
  }

  bool appliesToDate(DateTime date) {
    if (!isActive) {
      return false;
    }

    final normalizedDate = normalizeDate(date)!;
    final normalizedSpecificDate = normalizeDate(specificDate);
    if (normalizedSpecificDate != null) {
      return normalizedSpecificDate == normalizedDate;
    }

    final dayNames = ['Su', 'Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa'];
    final dayCode = dayNames[normalizedDate.weekday % 7];
    return days.contains(dayCode);
  }

  String get scheduleLabel {
    final normalizedSpecificDate = normalizeDate(specificDate);
    if (normalizedSpecificDate != null) {
      return '${normalizedSpecificDate.month}/${normalizedSpecificDate.day}/${normalizedSpecificDate.year}';
    }

    return days.join(', ');
  }

  Map<String, Object?> toMap() {
    return {
      if (id != null) 'id': id,
      'title': title,
      'days': days.join(','),
      'specificDate': _serializeDate(specificDate),
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
      specificDate: _deserializeDate(map['specificDate']),
      isActive: map['isActive'] == 1,
    );
  }
}