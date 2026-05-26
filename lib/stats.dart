import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'db_helper.dart';


class Stats extends StatefulWidget {
  const Stats({super.key});

  @override
  _StatsState createState() => _StatsState();
}

class _StatsState extends State<Stats> {
  bool _isLoading = true;
  int _doneCount = 0;
  int _skippedCount = 0;

  int get _totalCount => _doneCount + _skippedCount;

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

    int done = 0;
    int skipped = 0;

    for (final log in logs) {
      if (log.status == 'done') {
        done++;
      } else if (log.status == 'skipped') {
        skipped++;
      }
    }

    if (!mounted) {
      return;
    }

    setState(() {
      _doneCount = done;
      _skippedCount = skipped;
      _isLoading = false;
    });
  }

  List<PieChartSectionData> _buildSections({
    required Color doneColor,
    required Color skippedColor,
  }) {
    final sections = <PieChartSectionData>[];

    if (_doneCount > 0) {
      sections.add(
        PieChartSectionData(
          value: _doneCount.toDouble(),
          color: doneColor,
          title: '',
          radius: 52,
        ),
      );
    }

    if (_skippedCount > 0) {
      sections.add(
        PieChartSectionData(
          value: _skippedCount.toDouble(),
          color: skippedColor,
          title: '',
          radius: 52,
        ),
      );
    }

    return sections;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final doneColor = colorScheme.primary;
    final skippedColor = colorScheme.tertiary;
    final total = _totalCount;
    final donePercent = total == 0 ? 0 : (_doneCount / total) * 100;

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 80,
        title: const Text('Stats'),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 6),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Last 7 days',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 18),
                      if (total == 0)
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 28),
                            child: Text('No logs found for this period'),
                          ),
                        )
                      else
                        SizedBox(
                          height: 220,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              PieChart(
                                PieChartData(
                                  sections: _buildSections(
                                    doneColor: doneColor,
                                    skippedColor: skippedColor,
                                  ),
                                  sectionsSpace: 2,
                                  centerSpaceRadius: 60,
                                ),
                              ),
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    '${donePercent.toStringAsFixed(0)}%',
                                    style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const Text('Done'),
                                ],
                              ),
                            ],
                          ),
                        ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _LegendItem(
                            color: doneColor,
                            label: 'Done ($_doneCount)',
                          ),
                          const SizedBox(width: 16),
                          _LegendItem(
                            color: skippedColor,
                            label: 'Skipped ($_skippedCount)',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendItem({
    required this.color,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(label),
      ],
    );
  }
}