import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/theme.dart';
import '../providers/weather_provider.dart';

class WeatherWidget extends StatelessWidget {
  const WeatherWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<WeatherProvider>(
      builder: (context, weatherProvider, _) {
        if (weatherProvider.isLoading) return _buildLoadingCard();

        if (weatherProvider.errorMessage != null) {
          return _buildErrorCard(context, weatherProvider.errorMessage!);
        }

        if (!weatherProvider.hasData) return _buildNoDataCard();

        final weather = weatherProvider.currentWeather!;

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppTheme.primaryBlue, AppTheme.lightBlue],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
            boxShadow: AppTheme.cardShadow,
          ),
          child: Row(
            children: [
              // Circular Icon
              Container(
                width: 68,
                height: 68,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: weather.iconUrl.isNotEmpty
                      ? Image.network(
                          weather.iconUrl,
                          width: 42,
                          height: 42,
                          errorBuilder: (c, e, st) => const Icon(
                            Icons.wb_sunny,
                            color: Colors.white,
                            size: 36,
                          ),
                        )
                      : const Icon(
                          Icons.wb_sunny,
                          color: Colors.white,
                          size: 36,
                        ),
                ),
              ),
              const SizedBox(width: 12),

              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        // Indikator lokasi (GPS atau fallback)
                        Icon(
                          weatherProvider.isUsingCurrentLocation
                              ? Icons.my_location
                              : Icons.location_on,
                          size: 14,
                          color: Colors.white70,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            weather.cityName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      weather.description,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(
                          Icons.water_drop,
                          size: 14,
                          color: Colors.white70,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '${weather.humidity}%',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Icon(Icons.air, size: 14, color: Colors.white70),
                        const SizedBox(width: 6),
                        Text(
                          '${weather.windSpeed.toStringAsFixed(1)} m/s',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Animated Temperature
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: weather.temperature),
                duration: const Duration(milliseconds: 900),
                builder: (context, value, child) {
                  return Text(
                    '${value.toStringAsFixed(0)}°C',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 36,
                      fontWeight: FontWeight.w800,
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLoadingCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.primaryBlue.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: AppTheme.primaryBlue,
            ),
          ),
          SizedBox(width: 12),
          Text(
            'Memuat cuaca...',
            style: TextStyle(color: AppTheme.primaryBlue),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorCard(BuildContext context, String error) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.accentRed.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: AppTheme.accentRed),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Gagal memuat cuaca',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: AppTheme.accentRed),
                ),
                const SizedBox(height: 6),
                Text(
                  // Show a short error detail to help debugging (trimmed)
                  error.length > 120 ? '${error.substring(0, 120)}...' : error,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.accentRed.withValues(alpha: 0.9),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Retry button
          IconButton(
            icon: const Icon(Icons.refresh, color: AppTheme.accentRed),
            onPressed: () {
              // Trigger a retry via the provider
              final provider = Provider.of<WeatherProvider>(
                context,
                listen: false,
              );
              provider.refreshWeather();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildNoDataCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.textLight.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
      ),
      child: const Row(
        children: [
          Icon(Icons.cloud_off, color: AppTheme.textSecondary),
          SizedBox(width: 12),
          Text(
            'Data cuaca tidak tersedia',
            style: TextStyle(color: AppTheme.textSecondary),
          ),
        ],
      ),
    );
  }
}
