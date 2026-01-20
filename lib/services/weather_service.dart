import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import '../config/constants.dart';
import '../models/weather_model.dart';

class WeatherService {
  // Gunakan API key langsung untuk memastikan berfungsi
  final String apiKey = '15e0683a33320c96b5f9d29dbb1e0cce';
  final String baseUrl = 'https://api.openweathermap.org/data/2.5';

  WeatherService() {
    debugPrint(
      'WeatherService initialized with API key: ${apiKey.substring(0, 8)}...',
    );
  }

  // Get weather berdasarkan lokasi saat ini (GPS)
  Future<WeatherModel> getCurrentLocationWeather() async {
    try {
      // Cek dan request permission lokasi
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      debugPrint('Location service enabled: $serviceEnabled');

      if (!serviceEnabled) {
        debugPrint('GPS tidak aktif, menggunakan data Pangandaran');
        // Fallback ke Pangandaran jika GPS mati
        return getPangandaranWeather();
      }

      LocationPermission permission = await Geolocator.checkPermission();
      debugPrint('Current location permission: $permission');

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        debugPrint('Requested location permission: $permission');

        if (permission == LocationPermission.denied) {
          debugPrint('Izin lokasi ditolak, menggunakan data Pangandaran');
          // Permission ditolak, fallback ke Pangandaran
          return getPangandaranWeather();
        }
      }

      if (permission == LocationPermission.deniedForever) {
        debugPrint(
          'Izin lokasi ditolak permanen, menggunakan data Pangandaran',
        );
        // Permission ditolak permanent, fallback ke Pangandaran
        return getPangandaranWeather();
      }

      // Dapatkan posisi saat ini dengan timeout lebih lama
      debugPrint('Mengambil posisi GPS...');
      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 15),
        ),
      );

      debugPrint(
        'Posisi GPS ditemukan: Lat ${position.latitude}, Lon ${position.longitude}',
      );

      // Fetch weather berdasarkan koordinat
      return getWeatherByCoordinates(position.latitude, position.longitude);
    } catch (e) {
      debugPrint('Error getting current location: $e');
      // Jika error apapun, fallback ke Pangandaran
      return getPangandaranWeather();
    }
  }

  // Get weather berdasarkan koordinat
  Future<WeatherModel> getWeatherByCoordinates(double lat, double lon) async {
    try {
      final url =
          '$baseUrl/weather?lat=$lat&lon=$lon&appid=$apiKey&units=metric&lang=id';
      debugPrint('Fetching weather from: $url');

      final response = await http
          .get(Uri.parse(url))
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              throw Exception('Request timeout');
            },
          );

      debugPrint('Weather API response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Mapping manual untuk kota-kota besar berdasarkan koordinat
        String cityName = _getCityNameFromCoordinates(lat, lon, data['name']);
        data['name'] = cityName;

        debugPrint(
          'Final weather data: ${data['name']} - ${data['main']['temp']}°C',
        );
        return WeatherModel.fromJson(data);
      } else if (response.statusCode == 401) {
        debugPrint('API key invalid, menggunakan data dummy');
        // API key invalid, return dummy data
        return _getDummyWeather();
      } else {
        debugPrint('API error: ${response.statusCode} - ${response.body}');
        throw Exception('Failed to load weather: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error in getWeatherByCoordinates: $e');
      // Return dummy data on error
      return _getDummyWeather();
    }
  }

  // Get weather untuk Pangandaran (fallback)
  Future<WeatherModel> getPangandaranWeather() async {
    try {
      final url =
          '$baseUrl/weather?lat=${AppConstants.pangandaranLat}&lon=${AppConstants.pangandaranLon}&appid=$apiKey&units=metric&lang=id';

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return WeatherModel.fromJson(data);
      } else if (response.statusCode == 401) {
        // API key invalid, return dummy data
        return _getDummyWeather();
      } else {
        throw Exception(
          'Failed to load weather: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      // Return dummy data on error
      return _getDummyWeather();
    }
  }

  // Alternative: Get weather by city name
  Future<WeatherModel> getWeatherByCity(String cityName) async {
    try {
      final url =
          '$baseUrl/weather?q=$cityName&appid=$apiKey&units=metric&lang=id';

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return WeatherModel.fromJson(data);
      } else {
        throw Exception(
          'Failed to load weather: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      throw Exception('Error fetching weather: $e');
    }
  }

  // Dummy weather data untuk fallback ketika API key invalid
  WeatherModel _getDummyWeather() {
    return WeatherModel(
      cityName: 'Pangandaran',
      temperature: 28.0,
      description: 'cerah',
      icon: '01d',
      humidity: 75,
      windSpeed: 3.5,
    );
  }

  // Mapping koordinat ke nama kota besar
  String _getCityNameFromCoordinates(double lat, double lon, String apiName) {
    // Bandung: -6.9 to -7.1, 107.5 to 107.7
    if (lat >= -7.1 && lat <= -6.9 && lon >= 107.5 && lon <= 107.7) {
      return 'Bandung';
    }
    // Jakarta: -6.0 to -6.4, 106.7 to 107.0
    else if (lat >= -6.4 && lat <= -6.0 && lon >= 106.7 && lon <= 107.0) {
      return 'Jakarta';
    }
    // Surabaya: -7.2 to -7.4, 112.6 to 112.8
    else if (lat >= -7.4 && lat <= -7.2 && lon >= 112.6 && lon <= 112.8) {
      return 'Surabaya';
    }
    // Semarang: -6.9 to -7.0, 110.3 to 110.5
    else if (lat >= -7.0 && lat <= -6.9 && lon >= 110.3 && lon <= 110.5) {
      return 'Semarang';
    }
    // Yogyakarta: -7.7 to -7.9, 110.3 to 110.5
    else if (lat >= -7.9 && lat <= -7.7 && lon >= 110.3 && lon <= 110.5) {
      return 'Yogyakarta';
    }

    // Jika tidak cocok dengan mapping, gunakan nama dari API
    return apiName;
  }
}
