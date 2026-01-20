class WeatherModel {
  final String cityName;
  final double temperature;
  final String description;
  final String icon;
  final int humidity;
  final double windSpeed;

  WeatherModel({
    required this.cityName,
    required this.temperature,
    required this.description,
    required this.icon,
    required this.humidity,
    required this.windSpeed,
  });

  factory WeatherModel.fromJson(Map<String, dynamic> json) {
    return WeatherModel(
      cityName: json['name'] as String? ?? '',
      temperature: (json['main']?['temp'] as num?)?.toDouble() ?? 0.0,
      description: json['weather']?[0]?['description'] as String? ?? '',
      icon: json['weather']?[0]?['icon'] as String? ?? '',
      humidity: json['main']?['humidity'] as int? ?? 0,
      windSpeed: (json['wind']?['speed'] as num?)?.toDouble() ?? 0.0,
    );
  }

  String get iconUrl => 'https://openweathermap.org/img/wn/$icon@2x.png';

  // Convert icon code to emoji
  String get weatherIcon {
    switch (icon) {
      case '01d':
        return '☀️';
      case '01n':
        return '🌙';
      case '02d':
        return '⛅';
      case '02n':
        return '☁️';
      case '03d':
      case '03n':
        return '☁️';
      case '04d':
      case '04n':
        return '☁️';
      case '09d':
      case '09n':
        return '🌧️';
      case '10d':
        return '🌦️';
      case '10n':
        return '🌧️';
      case '11d':
      case '11n':
        return '⛈️';
      case '13d':
      case '13n':
        return '❄️';
      case '50d':
      case '50n':
        return '🌫️';
      default:
        return '🌤️';
    }
  }
}
