import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class WeatherMain extends StatefulWidget {
  const WeatherMain({Key? key}) : super(key: key);

  @override
  _WeatherMainState createState() => _WeatherMainState();
}

class _WeatherMainState extends State<WeatherMain> {
  String weatherData = '';
  String locationData = '';
  String API_KEY = '95d77ff68af3e20d27da4d6f00a1f4ec';
  IconData weatherIcon = Icons.cloud;

  Future<void> getPosition() async {
    LocationPermission permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      print('Location permission denied');
    } else if (permission == LocationPermission.deniedForever) {
      print('Location permission denied forever');
    } else {
      print('Location permission granted');
    }

    var currentPosition = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.low);
    // print(currentPosition);

    getWeather(lat: currentPosition.latitude.toString(), lon: currentPosition.longitude.toString());
  }

  Future<void> getWeather({required String lat, required String lon}) async {
    var response = await http.get(
      Uri.parse(
          'http://api.openweathermap.org/data/2.5/weather?lat=$lat&lon=$lon&appid=$API_KEY&units=metric'),
    );

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      // print(data);
      setState(() {
        locationData = 'Location: ${data['name']}';
        weatherData = 'Temperature: ${data ['main']['temp']}°C\n'
            'Weather: ${data['weather'][0]['description']}';
        weatherIcon = getWeatherIcon(data['weather'][0]['id']);
      });
    } else {
      throw Exception('Failed to load weather data');
    }
  }

  IconData getWeatherIcon(int condition) {
    if (condition < 300) {
      return Icons.bolt; // Thunderstorm
    } else if (condition < 400) {
      return Icons.umbrella; // Drizzle
    } else if (condition < 600) {
      return Icons.beach_access; // Rain
    } else if (condition < 700) {
      return Icons.snowing; // Snow
    } else if (condition < 800) {
      return Icons.foggy; // Atmosphere
    } else if (condition == 800) {
      return Icons.wb_sunny; // Clear
    } else if (condition <= 804) {
      return Icons.cloud; // Clouds
    } else {
      return Icons.error_outline; // Unknown
    }
  }

  @override
  void initState() {
    super.initState();
    getPosition();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Weather App'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(locationData),
            const SizedBox(height: 20),
            Icon(weatherIcon, size: 50),
            const SizedBox(height: 20),
            Text(weatherData),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.refresh),
        onPressed: () {
          setState(() {
            getPosition();
          });
      }),
    );
  }
}
