import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_weather/main.dart';
import 'package:flutter_weather/src/model/weather.dart';
import 'package:flutter_weather/src/widgets/current_conditions.dart';
import 'package:flutter_weather/src/widgets/empty_widget.dart';
import 'package:flutter_weather/src/widgets/temperature_line_chart.dart';

class WeatherSwipePager extends StatelessWidget {
  const WeatherSwipePager({
    Key? key,
    required this.weather,
  }) : super(key: key);

  final Weather weather;

  @override
  Widget build(BuildContext context) {
    ThemeData? appTheme = AppStateContainer.of(context)?.theme;

    return Container(
      width: MediaQuery.of(context).size.width,
      height: 300,
      child: CarouselSlider.builder(
        options: CarouselOptions(
          height: double.infinity,
          aspectRatio: 16 / 9,
          viewportFraction: 0.8,
          initialPage: 0,
          enableInfiniteScroll: true,
          reverse: false,
          autoPlay: false,
          autoPlayInterval: Duration(seconds: 3),
          autoPlayAnimationDuration: Duration(milliseconds: 800),
          autoPlayCurve: Curves.fastOutSlowIn,
          enlargeCenterPage: false,
          enlargeFactor: 0.3,
          scrollDirection: Axis.horizontal,
        ),
        itemCount: 2,
        itemBuilder: (BuildContext context, int itemIndex, int pageViewIndex) => Container(
          child: itemIndex == 0
              ? CurrentConditions(weather: weather)
              : itemIndex == 1
                  ? TemperatureLineChart(
                      weather.forecast.toChartData(),
                      animate: true,
                    )
                  : EmptyWidget(),
        ),
      ),
    );
  }
}
