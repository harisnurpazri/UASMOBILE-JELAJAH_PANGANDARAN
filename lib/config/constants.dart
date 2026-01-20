class AppConstants {
  // Supabase Configuration
  static const String supabaseUrl = 'https://egcfnzthyvwepakxwmnd.supabase.co';
  static const String supabaseAnonKey =
      'sb_publishable_2cxJPfFBzoHbpYf2dVnStw_Jdq9Nx9S';

  // OpenWeatherMap Configuration
  // Gunakan API key langsung untuk development
  static String get weatherApiKey {
    // Prioritas 1: Gunakan environment variable jika ada
    const envKey = String.fromEnvironment('WEATHER_API_KEY', defaultValue: '');
    if (envKey.isNotEmpty) return envKey;

    // Prioritas 2: Gunakan key development langsung
    return '15e0683a33320c96b5f9d29dbb1e0cce';
  }

  static const String weatherBaseUrl =
      'https://api.openweathermap.org/data/2.5';
  static const String pangandaranCity = 'Pangandaran';
  static const double pangandaranLat = -7.6839;
  static const double pangandaranLon = 108.6500;

  // API Endpoints
  static const String wisataEndpoint = '/rest/v1/wisata';
  static const String profilesEndpoint = '/rest/v1/profiles';
  static const String wishlistEndpoint = '/rest/v1/wishlist';

  // Categories (Synchronized between Admin and User)
  static const List<String> wisataCategories = [
    'Semua',
    'Pantai',
    'Alam',
    'Wahana',
  ];

  // Categories for Admin Form (without 'Semua')
  static const List<String> adminWisataCategories = [
    'Pantai',
    'Alam',
    'Wahana',
  ];

  // Default Values
  static const String defaultImageUrl =
      'https://via.placeholder.com/400x300?text=No+Image';
}
