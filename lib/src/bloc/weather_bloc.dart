import 'package:bloc/bloc.dart';
import 'package:weather/src/model/weather.dart';

import 'package:weather/src/bloc/weather_event.dart';
import 'package:weather/src/bloc/weather_state.dart';
import 'package:weather/src/repository/weather_repository.dart';
import 'package:weather/src/api/http_exception.dart';

class WeatherBloc extends Bloc<WeatherEvent, WeatherState> {
  final WeatherRepository weatherRepository;

  WeatherBloc({required this.weatherRepository}) : super(WeatherEmpty()) {
    on<WeatherEvent>((event, emit) async {
      if (event is FetchWeather) {
        emit(WeatherLoading());
        try {
          final Weather weather = await weatherRepository.getWeather(
            event.cityName,
            latitude: event.latitude,
            longitude: event.longitude,
          );
          emit(WeatherLoaded(weather: weather));
        } catch (exception) {
          print(exception);
          if (exception is HTTPException) {
            emit(WeatherError(errorCode: exception.code));
          } else {
            emit(WeatherError(errorCode: 500));
          }
        }
      }
    });
  }
}
