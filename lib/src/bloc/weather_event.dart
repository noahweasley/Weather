import 'package:equatable/equatable.dart';

abstract class WeatherEvent extends Equatable {
  final String? cityName;
  final double? longitude;
  final double? latitude;

  WeatherEvent({this.cityName, this.longitude, this.latitude});

  @override
  List<Object?> get props => [cityName, longitude, latitude];
}

class FetchWeather extends WeatherEvent {
  FetchWeather({String? cityName, double? longitude, double? latitude})
      : super(cityName: cityName, longitude: longitude, latitude: latitude);
}

class RefreshWeather extends WeatherEvent {
  RefreshWeather({String? cityName, double? longitude, double? latitude})
      : super(cityName: cityName, longitude: longitude, latitude: latitude);
}
