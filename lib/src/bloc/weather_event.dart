import 'package:equatable/equatable.dart';

abstract class WeatherEvent extends Equatable {
  WeatherEvent();
}

class FetchWeather extends WeatherEvent {
  final String? cityName;
  final double? longitude;
  final double? latitude;

  FetchWeather({this.cityName, this.longitude, this.latitude});

  @override
  List<Object?> get props => [cityName, longitude, latitude];
}
