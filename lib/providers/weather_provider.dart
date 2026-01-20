import 'package:flutter/foundation.dart';
import '../models/weather_model.dart';
import '../services/weather_service.dart';

class WeatherProvider with ChangeNotifier {
  final WeatherService _weatherService = WeatherService();

  WeatherModel? _currentWeather;
  bool _isLoading = false;
  String? _errorMessage;
  DateTime? _lastUpdated;
  bool _isUsingCurrentLocation = true;

  // Getters
  WeatherModel? get currentWeather => _currentWeather;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  DateTime? get lastUpdated => _lastUpdated;
  bool get hasData => _currentWeather != null;
  bool get isUsingCurrentLocation => _isUsingCurrentLocation;

  // Load weather dari lokasi saat ini (auto-detect GPS)
  Future<void> loadCurrentLocationWeather({bool forceRefresh = false}) async {
    // Check if we need to refresh (every 30 minutes)
    if (!forceRefresh && _currentWeather != null && _lastUpdated != null) {
      final difference = DateTime.now().difference(_lastUpdated!);
      if (difference.inMinutes < 30) {
        return; // Data still fresh
      }
    }

    try {
      _setLoading(true);
      _errorMessage = null;

      _currentWeather = await _weatherService.getCurrentLocationWeather();
      _lastUpdated = DateTime.now();
      // Cek apakah menggunakan lokasi real atau fallback
      _isUsingCurrentLocation = _currentWeather?.cityName != 'Pangandaran';
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Gagal memuat data cuaca: $e';
      _isUsingCurrentLocation = false;
      debugPrint('Error loading weather: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Load weather for Pangandaran (tetap ada untuk backward compatibility)
  Future<void> loadPangandaranWeather({bool forceRefresh = false}) async {
    // Check if we need to refresh (every 30 minutes)
    if (!forceRefresh && _currentWeather != null && _lastUpdated != null) {
      final difference = DateTime.now().difference(_lastUpdated!);
      if (difference.inMinutes < 30) {
        return; // Data still fresh
      }
    }

    try {
      _setLoading(true);
      _errorMessage = null;

      _currentWeather = await _weatherService.getPangandaranWeather();
      _lastUpdated = DateTime.now();
      _isUsingCurrentLocation = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Gagal memuat data cuaca: $e';
      debugPrint('Error loading weather: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Load weather by city name
  Future<void> loadWeatherByCity(String cityName) async {
    try {
      _setLoading(true);
      _errorMessage = null;

      _currentWeather = await _weatherService.getWeatherByCity(cityName);
      _lastUpdated = DateTime.now();
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Gagal memuat data cuaca: $e';
      debugPrint('Error loading weather: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Refresh weather (gunakan lokasi saat ini)
  Future<void> refreshWeather() async {
    await loadCurrentLocationWeather(forceRefresh: true);
  }

  // Get temperature in Celsius
  String get temperatureCelsius {
    if (_currentWeather == null) return '--';
    return '${_currentWeather!.temperature.toStringAsFixed(0)}°C';
  }

  // Get weather description
  String get description {
    if (_currentWeather == null) return 'Tidak ada data';
    return _currentWeather!.description;
  }

  // Get weather icon URL
  String? get iconUrl {
    return _currentWeather?.iconUrl;
  }

  // Clear error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
