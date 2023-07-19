import 'dart:js_interop';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:weather/main.dart';
import 'package:weather/src/model/weather.dart';

/// Renders a line chart from forecast data
/// x axis - date
/// y axis - temperature
class TemperatureLineChart extends StatelessWidget {
  final List<Color> gradientColors = [Colors.cyan, Colors.blue];
  final List<Weather> weathersForecasts;
  final bool? animate;

  TemperatureLineChart(this.weathersForecasts, {this.animate});

  @override
  Widget build(BuildContext context) {
    ThemeData? appTheme = AppStateContainer.of(context)?.theme;
    int dateIndex = 0;
    
    return AspectRatio(
      aspectRatio: 1.70,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: LineChart(
          LineChartData(
            titlesData: FlTitlesData(
              show: true,
              rightTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              topTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 30,
                  interval: 1,
                  getTitlesWidget: (value, meta) => bottomTitleWidgets(weathersForecasts, appTheme, value, meta),
                ),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  interval: 1,
                  getTitlesWidget: (value, meta) => leftTitleWidgets(weathersForecasts, appTheme, value, meta),
                  reservedSize: 42,
                ),
              ),
            ),
            borderData: FlBorderData(
              show: true,
              border: Border.all(color: const Color(0xff37434d)),
            ),
            minX: 0,
            maxX: weathersForecasts.length.toDouble(),
            minY: 0,
            maxY:  50,
            lineBarsData: [
              LineChartBarData(
                spots: weathersForecasts.map((e) => FlSpot(dateIndex++ as double, e.temperature.celsius)).toList(),
                isCurved: true,
                gradient: LinearGradient(
                  colors: gradientColors,
                ),
                barWidth: 5,
                isStrokeCapRound: true,
                dotData: const FlDotData(
                  show: false,
                ),
                belowBarData: BarAreaData(
                  show: true,
                  gradient: LinearGradient(
                    colors: gradientColors.map((color) => color.withOpacity(0.3)).toList(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget bottomTitleWidgets(List<Weather> forecast, ThemeData? theme, double value, TitleMeta meta) {
    final style = TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: theme?.colorScheme.secondary);

    Widget text;
    switch (value.toInt()) {
      case 2:
        text = Text(DateFormat('dd MMM').format(forecast[value.toInt() - 1].date), style: style);
        break;
      case 20:
        text = Text(DateFormat('dd MMM').format(forecast[value.toInt() - 1].date), style: style);
        break;
      case 38:
        text = Text(DateFormat('dd MMM').format(forecast[value.toInt() - 1].date), style: style);
        break;
      default:
        text =  Text('', style: style);
        break;
    }

    return SideTitleWidget(
      axisSide: meta.axisSide,
      child: text,
    );
  }

  Widget leftTitleWidgets(List<Weather> forecast, ThemeData? theme, double value, TitleMeta meta) {
    final style = TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: theme?.colorScheme.secondary);

    String text;
    
    switch (value.toInt()) {
      case 1:
        text = '0°';
        break;
      case 20:
        text = '20°';
        break;
      case 40:
        text = '40°';
        break;
      default:
        return Container();
    }

    return Text(text, style: style, textAlign: TextAlign.left);
  }
}
