import 'package:flutter/material.dart';
import 'db_helper.dart';
import 'models/day_stats.dart';
import 'charts/donut_chart.dart';
import 'charts/bar_chart.dart';


class Stats extends StatefulWidget {
  const Stats({super.key});

  @override
  _StatsState createState() => _StatsState();
}

class _StatsState extends State<Stats> {
  bool _isLoading = true;
  int _doneCount = 0;
  int _skippedCount = 0;
  List<DayStats> _dailyStats = [];
  int _selectedDays = 7;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    setState(() => _isLoading = true);

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final endDate = today.subtract(const Duration(days: 1));
    final startDate = endDate.subtract(Duration(days: _selectedDays - 1));

    final logs = await DbHelper.getLogsBetweenDates(startDate, endDate);

    int totalDone = 0;
    int totalSkipped = 0;

    final dailyMap = <DateTime, DayStats>{};
    for (var i = 0; i < _selectedDays; i++) {
      final date = startDate.add(Duration(days: i));
      dailyMap[date] = DayStats(date: date, done: 0, skipped: 0);
    }

    for (final log in logs) {
      final logDate = DateTime(log.date.year, log.date.month, log.date.day);
      if (dailyMap.containsKey(logDate)) {
        final current = dailyMap[logDate]!;
        if (log.status == 'done') {
          dailyMap[logDate] = DayStats(
            date: logDate,
            done: current.done + 1,
            skipped: current.skipped,
          );
          totalDone++;
        } else if (log.status == 'skipped') {
          dailyMap[logDate] = DayStats(
            date: logDate,
            done: current.done,
            skipped: current.skipped + 1,
          );
          totalSkipped++;
        }
      }
    }

    if (!mounted) {
      return;
    }

    setState(() {
      _doneCount = totalDone;
      _skippedCount = totalSkipped;
      _dailyStats = dailyMap.values.toList();
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 80,
        title: const Text('Stats'),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Column(
                  children: [
                    SegmentedButton<int>(
                      segments: const [
                        ButtonSegment(value: 7, label: Text('7 days')),
                        ButtonSegment(value: 30, label: Text('30 days')),
                      ],
                      selected: {_selectedDays},
                      onSelectionChanged: (selection) {
                        setState(() => _selectedDays = selection.first);
                        _loadStats();
                      },
                    ),
                    const SizedBox(height: 8),
                    DonutChart(
                      doneCount: _doneCount,
                      skippedCount: _skippedCount,
                      title: _selectedDays == 7 ? 'Weekly Completion' : '30-Day Completion',
                    ),
                    const SizedBox(height: 8),
                    BarChart(dailyStats: _dailyStats),
                  ],
                ),
              ),
            ),
    );
  }
}