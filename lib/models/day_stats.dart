class DayStats {
  final DateTime date;
  final int done;
  final int skipped;

  DayStats({
    required this.date,
    required this.done,
    required this.skipped,
  });

  int get total => done + skipped;
  double get percentage => total == 0 ? 0 : (done / total) * 100;
  String get dayLabel =>
      ['Su', 'Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa'][date.weekday % 7];
}
