import 'package:flutter/material.dart';
import 'db_helper.dart';
import 'models/day_stats.dart';
import 'charts/weekly_donut_chart.dart';
import 'charts/weekly_bar_chart.dart';


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

  @override
  void initState() {
    super.initState();
    _loadWeeklyStats();
  }

  Future<void> _loadWeeklyStats() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final endDate = today.subtract(const Duration(days: 1));
    final startDate = endDate.subtract(const Duration(days: 6));

    final logs = await DbHelper.getLogsBetweenDates(startDate, endDate);

    // Calculate total counts
    int totalDone = 0;
    int totalSkipped = 0;

    // Build daily stats
    final dailyMap = <DateTime, DayStats>{};
    for (var i = 0; i < 7; i++) {
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
                    WeeklyDonutChart(
                      doneCount: _doneCount,
                      skippedCount: _skippedCount,
                    ),
                    const SizedBox(height: 16),
                    WeeklyBarChart(dailyStats: _dailyStats),
                  ],
                ),
              ),
            ),
    );
  }
}