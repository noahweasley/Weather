// import 'package:charts_flutter/flutter.dart' as charts;
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

/// Renders a line chart from forecast data
/// x axis - date
/// y axis - temperature
class TemperatureLineChart extends StatelessWidget {
  final List<LineChartBarData> weathers;
  final bool? animate;

  TemperatureLineChart(this.weathers, {this.animate});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(40.0),
      child: LineChart(
        LineChartData(
          lineBarsData: weathers,
          minX: 0,
          maxX: 10,
          maxY: 50,
          minY: 0,
        ),
        duration: Duration(milliseconds: 150), // Optional
        curve: Curves.linear, // Optional
      ),
    );
  }
}
