import 'package:flutter/material.dart';
import 'package:flutter_weather/main.dart';
import 'package:flutter_weather/src/bloc/weather_event.dart';
import 'package:flutter_weather/src/bloc/weather_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_weather/src/widgets/weather_widget.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:async';

import '../bloc/weather_bloc.dart';

enum OptionsMenu { changeCity, settings }

class WeatherScreen extends StatefulWidget {
  @override
  _WeatherScreenState createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> with TickerProviderStateMixin {
  late WeatherBloc _weatherBloc;
  String? _cityName = 'Awka';
  late Animation<double> _fadeAnimation;
  late AnimationController _fadeController;

  @override
  void initState() {
    super.initState();

    _weatherBloc = BlocProvider.of<WeatherBloc>(context);

    const refreshInterval = Duration(minutes: 1);
    Timer.periodic(refreshInterval, (Timer t) => _weatherBloc.add(RefreshWeather(cityName: _cityName)));

    _fetchWeatherWithLocation().catchError((error) {
      _fetchWeatherWithCity();
    });

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    );
  }

  @override
  Widget build(BuildContext context) {
    ThemeData? appTheme = AppStateContainer.of(context)?.theme;

    return Scaffold(
        appBar: AppBar(
          backgroundColor: appTheme?.primaryColor,
          elevation: 0,
          title: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                DateFormat('EEEE, d MMMM yyyy').format(DateTime.now()),
                style: TextStyle(
                  color: appTheme?.colorScheme.secondary.withAlpha(80),
                  fontSize: 14,
                ),
              )
            ],
          ),
          actions: <Widget>[
            IconButton(
              tooltip: "Refresh",
              onPressed: () => _weatherBloc.add(FetchWeather(cityName: _cityName)),
              icon: Icon(
                Icons.refresh,
                color: appTheme?.colorScheme.secondary,
              ),
            ),
            PopupMenuButton<OptionsMenu>(
              color: appTheme?.primaryColorLight,
              child: Icon(
                Icons.more_vert,
                color: appTheme?.colorScheme.secondary,
              ),
              onSelected: this._onOptionMenuItemSelected,
              itemBuilder: (context) => <PopupMenuEntry<OptionsMenu>>[
                PopupMenuItem<OptionsMenu>(
                  value: OptionsMenu.changeCity,
                  child: Text(
                    "Change city",
                    style: TextStyle(
                      color: appTheme?.colorScheme.secondary,
                    ),
                  ),
                ),
                PopupMenuItem<OptionsMenu>(
                  value: OptionsMenu.settings,
                  child: Text(
                    "Settings",
                    style: TextStyle(
                      color: appTheme?.colorScheme.secondary,
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
        backgroundColor: Colors.white,
        body: Material(
          child: Container(
            constraints: BoxConstraints.expand(),
            decoration: BoxDecoration(color: appTheme?.primaryColor),
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: BlocBuilder<WeatherBloc, WeatherState>(builder: (_, WeatherState weatherState) {
                _fadeController.reset();
                _fadeController.forward();

                if (weatherState is WeatherLoaded) {
                  if (weatherState.weather != null) {
                    this._cityName = weatherState.weather!.cityName;
                    return WeatherWidget(
                      weather: weatherState.weather!,
                    );
                  }
                } else if (weatherState is WeatherError || weatherState is WeatherEmpty) {
                  String errorText = 'There was an error fetching weather data';
                  if (weatherState is WeatherError) {
                    if (weatherState.errorCode == 404) {
                      errorText = 'We have trouble fetching weather for $_cityName';
                    }
                  }
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Icon(
                        Icons.error_outline,
                        color: Colors.redAccent,
                        size: 48,
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Text(
                        errorText,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.red,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(14),
                        child: TextButton(
                          style: TextButton.styleFrom(
                            foregroundColor: appTheme?.colorScheme.secondary,
                            elevation: 1,
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(14),
                            child: Text("Try Again"),
                          ),
                          onPressed: _fetchWeatherWithCity,
                        ),
                      ),
                    ],
                  );
                } else if (weatherState is WeatherLoading) {
                  return Center(
                    child: CircularProgressIndicator(
                      backgroundColor: appTheme?.colorScheme.secondary,
                    ),
                  );
                }
                return Container(
                  child: Text('No city set'),
                );
              }),
            ),
          ),
        ));
  }

  void _showCityChangeDialog() {
    showDialog(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          ThemeData? appTheme = AppStateContainer.of(context)?.theme;

          return AlertDialog(
            backgroundColor: appTheme?.primaryColorLight,
            title: Text('Change city',
                style: TextStyle(
                  color: appTheme?.colorScheme.secondary,
                )),
            actions: <Widget>[
              TextButton(
                child: Text('ok'),
                style: TextButton.styleFrom(
                  foregroundColor: appTheme?.colorScheme.secondary,
                  elevation: 1,
                ),
                onPressed: () {
                  _fetchWeatherWithCity();
                  Navigator.of(context).pop();
                },
              ),
            ],
            content: TextField(
              autofocus: true,
              onChanged: (text) {
                _cityName = text;
              },
              decoration: InputDecoration(
                  hintText: 'Name of your city',
                  hintStyle: TextStyle(
                    color: appTheme?.colorScheme.secondary,
                  ),
                  suffixIcon: GestureDetector(
                    onTap: () {
                      _fetchWeatherWithLocation().catchError((error) {
                        _fetchWeatherWithCity();
                      });
                      Navigator.of(context).pop();
                    },
                    child: Icon(
                      Icons.my_location,
                      color: appTheme?.colorScheme.secondary,
                      size: 16,
                    ),
                  )),
              style: TextStyle(
                color: appTheme?.colorScheme.secondary,
              ),
              cursorColor: Colors.black,
            ),
          );
        });
  }

  _onOptionMenuItemSelected(OptionsMenu item) {
    switch (item) {
      case OptionsMenu.changeCity:
        this._showCityChangeDialog();
        break;
      case OptionsMenu.settings:
        Navigator.of(context).pushNamed("/settings");
        break;
    }
  }

  _fetchWeatherWithCity() {
    _weatherBloc.add(FetchWeather(cityName: _cityName));
  }

  _fetchWeatherWithLocation() async {
    var permissionResult = await Permission.locationWhenInUse.status;

    switch (permissionResult) {
      case PermissionStatus.restricted:
      case PermissionStatus.permanentlyDenied:
        print('location permission denied');
        _showLocationDeniedDialog();
        break;

      case PermissionStatus.denied:
        await Permission.locationWhenInUse.request();
        _fetchWeatherWithLocation();
        break;

      case PermissionStatus.limited:
      case PermissionStatus.granted:
        print('getting location');
        Position position =
            await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.low, timeLimit: Duration(seconds: 2));

        print(position.toString());

        _weatherBloc.add(FetchWeather(
          longitude: position.longitude,
          latitude: position.latitude,
        ));
        break;
    }
  }

  void _showLocationDeniedDialog() {
    showDialog(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          ThemeData? appTheme = AppStateContainer.of(context)?.theme;

          return AlertDialog(
            backgroundColor: appTheme?.primaryColorLight,
            title: Text('Location is disabled :(', style: TextStyle(color: Colors.black)),
            actions: <Widget>[
              TextButton(
                child: Text('Enable!'),
                style: TextButton.styleFrom(
                  foregroundColor: appTheme?.colorScheme.secondary,
                  elevation: 1,
                ),
                onPressed: () {
                  openAppSettings();
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        });
  }
}
