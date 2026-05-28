import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart' as fl;
import '../models/day_stats.dart';

class BarChart extends StatelessWidget {
  final List<DayStats> dailyStats;

  const BarChart({super.key, required this.dailyStats});

  bool get _isLargePeriod => dailyStats.length > 7;

  List<fl.BarChartGroupData> _buildGroups(Color doneColor) {
    final barWidth = _isLargePeriod ? 6.0 : 12.0;
    return List.generate(dailyStats.length, (index) {
      return fl.BarChartGroupData(
        x: index,
        barRods: [
          fl.BarChartRodData(
            toY: dailyStats[index].percentage,
            color: doneColor,
            width: barWidth,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(3)),
          ),
        ],
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final doneColor = Theme.of(context).colorScheme.primary;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Daily completion',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 18),
            if (dailyStats.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 28),
                  child: Text('No data available'),
                ),
              )
            else
              SizedBox(
                height: 240,
                child: fl.BarChart(
                  fl.BarChartData(
                    barGroups: _buildGroups(doneColor),
                    maxY: 100,
                    titlesData: fl.FlTitlesData(
                      bottomTitles: fl.AxisTitles(
                        sideTitles: fl.SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            final index = value.toInt();
                            if (index < 0 || index >= dailyStats.length) {
                              return const SizedBox.shrink();
                            }
                              if (_isLargePeriod && index % 5 != 0) {
                                return const SizedBox.shrink();
                              }
                              final date = dailyStats[index].date;
                              final label = _isLargePeriod
                                  ? '${date.month}/${date.day}'
                                  : dailyStats[index].dayLabel;
                              return Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Text(
                                  label,
                                  style: const TextStyle(fontSize: 10),
                              ),
                            );
                          },
                        ),
                      ),
                      leftTitles: fl.AxisTitles(
                        sideTitles: fl.SideTitles(
                          showTitles: true,
                          interval: 25,
                          reservedSize: 40,
                          getTitlesWidget: (value, meta) {
                            return fl.SideTitleWidget(
                              meta: meta,
                              child: Text(
                                '${value.toInt()}%',
                                style: const TextStyle(fontSize: 10),
                              ),
                            );
                          },
                        ),
                      ),
                      topTitles: const fl.AxisTitles(
                        sideTitles: fl.SideTitles(showTitles: false),
                      ),
                      rightTitles: const fl.AxisTitles(
                        sideTitles: fl.SideTitles(showTitles: false),
                      ),
                    ),
                    borderData: fl.FlBorderData(show: false),
                    gridData: const fl.FlGridData(show: false),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
