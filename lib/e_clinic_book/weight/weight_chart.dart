import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:vet_assist/e_clinic_book/weight/weight_model.dart';

class WeightChart extends StatelessWidget {
  final List<WeightEntry> entries;

  const WeightChart({super.key, required this.entries});

  @override
  Widget build(BuildContext context) {
    if (entries.length < 2) {
      return const Padding(
        padding: EdgeInsets.all(16.0),
        child: Text(
          'Add at least 2 weight entries to see the chart',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    // Sort entries by date to ensure proper rendering
    final sortedEntries = List<WeightEntry>.from(entries)
      ..sort((a, b) => a.date.compareTo(b.date));

    // Convert entries to FlSpots using index for x-values
    final spots = List.generate(
      sortedEntries.length,
      (index) => FlSpot(index.toDouble(), sortedEntries[index].weight),
    );

    return SizedBox(
      height: 250,
      child: LineChart(
        LineChartData(
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              color: Colors.tealAccent,
              barWidth: 2,
              dotData: FlDotData(show: true),
              belowBarData: BarAreaData(
                show: true,
                color: Colors.teal.withOpacity(0.2),
              ),
            ),
          ],
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 1,
                reservedSize: 40,
                getTitlesWidget: (value, meta) {
                  return Text(
                    '${value.toStringAsFixed(1)} kg',
                    style: const TextStyle(color: Colors.white, fontSize: 10),
                  );
                },
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                interval: 1,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index >= 0 && index < sortedEntries.length) {
                    final date = sortedEntries[index].date;
                    return Text(
                      DateFormat.Md().format(date), // MM/dd
                      style: const TextStyle(color: Colors.white, fontSize: 10),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          gridData: FlGridData(show: true),
          borderData: FlBorderData(show: true),
          minX: 0,
          maxX: (sortedEntries.length - 1).toDouble(),
        ),
      ),
    );
  }
}
