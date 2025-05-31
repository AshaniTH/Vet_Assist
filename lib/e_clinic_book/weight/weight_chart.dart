import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:vet_assist/e_clinic_book/models/weight_model.dart';

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

    final series = [
      charts.Series<WeightEntry, DateTime>(
        id: 'Weight',
        colorFn: (_, __) => charts.MaterialPalette.teal.shadeDefault,
        domainFn: (WeightEntry entry, _) => entry.date,
        measureFn: (WeightEntry entry, _) => entry.weight,
        data: entries,
      ),
    ];

    return SizedBox(
      height: 200,
      child: charts.TimeSeriesChart(
        series,
        animate: true,
        defaultRenderer: charts.LineRendererConfig(
          includeArea: true,
          stacked: false,
        ),
        primaryMeasureAxis: const charts.NumericAxisSpec(
          renderSpec: charts.GridlineRendererSpec(
            labelStyle: charts.TextStyleSpec(
              fontSize: 10,
              color: charts.MaterialPalette.white,
            ),
          ),
        ),
        domainAxis: const charts.DateTimeAxisSpec(
          renderSpec: charts.GridlineRendererSpec(
            labelStyle: charts.TextStyleSpec(
              fontSize: 10,
              color: charts.MaterialPalette.white,
            ),
          ),
        ),
        behaviors: [
          charts.SeriesLegend(
            position: charts.BehaviorPosition.top,
            outsideJustification: charts.OutsideJustification.start,
          ),
          charts.ChartTitle(
            'Date',
            behaviorPosition: charts.BehaviorPosition.bottom,
            titleStyleSpec: const charts.TextStyleSpec(
              fontSize: 11,
              color: charts.MaterialPalette.white,
            ),
          ),
          charts.ChartTitle(
            'Weight (kg)',
            behaviorPosition: charts.BehaviorPosition.start,
            titleStyleSpec: const charts.TextStyleSpec(
              fontSize: 11,
              color: charts.MaterialPalette.white,
            ),
          ),
        ],
      ),
    );
  }
}
