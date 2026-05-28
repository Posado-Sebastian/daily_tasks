import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class DonutChart extends StatelessWidget {
  final int doneCount;
  final int skippedCount;
  final String title;

  const DonutChart({
    super.key,
    required this.doneCount,
    required this.skippedCount,
    required this.title,
  });

  int get _total => doneCount + skippedCount;

  List<PieChartSectionData> _buildSections(
    Color doneColor,
    Color skippedColor,
  ) {
    return [
      if (doneCount > 0)
        PieChartSectionData(
          value: doneCount.toDouble(),
          color: doneColor,
          title: '',
          radius: 52,
        ),
      if (skippedCount > 0)
        PieChartSectionData(
          value: skippedCount.toDouble(),
          color: skippedColor,
          title: '',
          radius: 52,
        ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final doneColor = colorScheme.primary;
    final skippedColor = colorScheme.tertiary;
    final total = _total;
    final donePercent = total == 0 ? 0 : (doneCount / total) * 100;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
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
                        sections: _buildSections(doneColor, skippedColor),
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
                _LegendItem(color: doneColor, label: 'Done ($doneCount)'),
                const SizedBox(width: 16),
                _LegendItem(
                  color: skippedColor,
                  label: 'Skipped ($skippedCount)',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendItem({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(label),
      ],
    );
  }
}
