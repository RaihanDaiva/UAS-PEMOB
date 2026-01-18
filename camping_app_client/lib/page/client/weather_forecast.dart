import 'package:flutter/material.dart';
import '../../models/campsite.dart';
import '../../services/api_admin_services.dart';

class WeatherForecast extends StatefulWidget {
  final Campsite campsite;
  final VoidCallback onBack;

  const WeatherForecast({
    Key? key,
    required this.campsite,
    required this.onBack,
  }) : super(key: key);

  @override
  State<WeatherForecast> createState() => _WeatherForecastState();
}

class _WeatherForecastState extends State<WeatherForecast> {
  Map<String, dynamic>? weatherData;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _fetchWeather();
  }

  Future<void> _fetchWeather() async {
    try {
      print('🌤️ Fetching weather for campsite: ${widget.campsite.id}');
      print('   Name: ${widget.campsite.name}');

      final data = await apiService.getWeatherForecast(
        widget.campsite.id,
        days: 8,
      );

      print('✅ Weather data keys: ${data.keys}');
      print('   Forecast count: ${data['forecast']?.length ?? 0}');

      if (data['forecast'] == null || (data['forecast'] as List).isEmpty) {
        throw Exception('No forecast data available');
      }

      setState(() {
        weatherData = data;
        loading = false;
      });
    } catch (e) {
      print('❌ Weather error: $e');
      setState(() => loading = false);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load weather: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFDBEAFE), Color(0xFFBFDBFE)],
          ),
        ),
        child: Column(
          children: [
            // Header
            Container(
              color: Colors.white,
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF3F4F6),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.arrow_back, size: 20),
                          onPressed: widget.onBack,
                          padding: EdgeInsets.zero,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Weather Forecast',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              widget.campsite.name,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Color(0xFF6B7280),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Content
            Expanded(
              child: loading
                  ? const Center(child: CircularProgressIndicator())
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Current Weather Card
                          _buildCurrentWeatherCard(),
                          const SizedBox(height: 24),

                          // 8-Day Forecast
                          const Text(
                            '8-Day Forecast',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1F2937),
                            ),
                          ),
                          const SizedBox(height: 12),
                          _buildForecastList(),
                          const SizedBox(height: 24),

                          // Legend
                          _buildLegend(),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentWeatherCard() {
    if (weatherData == null) {
      return Center(child: Text('No weather data available'));
    }

    final forecast = weatherData!['forecast'] as List?;
    if (forecast == null || forecast.isEmpty) {
      return Center(child: Text('Forecast data is empty'));
    }

    // Find today's index (should be 0 or 1)
    final today = forecast.length > 1 ? forecast[1] : forecast[0];

    final tempMax = (today['temperature_max'] ?? 25).toDouble();
    final tempMin = (today['temperature_min'] ?? 20).toDouble();
    final weatherCode = today['weather_code'] ?? 0;
    final precipitation = (today['precipitation_probability'] ?? 0).toDouble();
    final windSpeed = (today['wind_speed'] ?? 0).toDouble();

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF3B82F6), Color(0xFF2563EB)],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Today\'s Weather',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.9),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${tempMax.round()}°',
                    style: const TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _getWeatherCondition(weatherCode),
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
              Icon(
                _getWeatherIcon(weatherCode),
                size: 80,
                color: Colors.white.withOpacity(0.9),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.only(top: 16),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: Colors.white.withOpacity(0.3)),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildWeatherStat(
                  Icons.air,
                  'Wind',
                  '${windSpeed.round()} km/h',
                ),
                _buildWeatherStat(
                  Icons.water_drop_outlined,
                  'Precipitation',
                  '${precipitation.round()}%',
                ),
                _buildWeatherStat(
                  Icons.check_circle_outline,
                  'Camping',
                  _getCampingSuitability(precipitation)['text'],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeatherStat(IconData icon, String label, String value) {
    return Column(
      children: [
        Icon(icon, size: 20, color: Colors.white.withOpacity(0.8)),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.8)),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildForecastList() {
    if (weatherData == null) {
      return const Center(child: Text('No weather data'));
    }

    final forecast = weatherData!['forecast'] as List?;
    if (forecast == null || forecast.isEmpty) {
      return const Center(child: Text('No forecast available'));
    }

    return Column(
      children: forecast.map<Widget>((day) {
        final date = day['date'] ?? '';
        final tempMax = (day['temperature_max'] ?? 25).toDouble();
        final tempMin = (day['temperature_min'] ?? 20).toDouble();
        final weatherCode = day['weather_code'] ?? 0;
        final precipitation = (day['precipitation_probability'] ?? 0)
            .toDouble();
        final windSpeed = (day['wind_speed'] ?? 0).toDouble();
        final suitability = _getCampingSuitability(precipitation);

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              // Date
              SizedBox(
                width: 50,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getDayLabel(date),
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                    Text(
                      date.length >= 5 ? date.substring(5) : date,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 0),

              // Weather Icon and Condition
              Expanded(
                child: Row(
                  children: [
                    Icon(
                      _getWeatherIcon(weatherCode),
                      size: 32,
                      color: _getWeatherIconColor(weatherCode),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _getWeatherCondition(weatherCode),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          '${tempMax.round()}°/${tempMin.round()}°C',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Stats
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.water_drop_outlined,
                        size: 12,
                        color: Color(0xFF6B7280),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${precipitation.round()}%',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.air, size: 12, color: Color(0xFF6B7280)),
                      const SizedBox(width: 4),
                      Text(
                        '${windSpeed.round()}km/h',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(width: 12),

              // Suitability Badge
              Container(
                width: 80,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: suitability['color'],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Center(
                  child: Text(
                    suitability['text'],
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildLegend() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Camping Suitability Guide',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          _buildLegendItem(
            const Color(0xFF10B981),
            'Excellent - Precipitation < 30%',
          ),
          const SizedBox(height: 8),
          _buildLegendItem(
            const Color(0xFFF59E0B),
            'Good - Precipitation 30-60%',
          ),
          const SizedBox(height: 8),
          _buildLegendItem(
            const Color(0xFFDC2626),
            'Not Ideal - Precipitation > 60%',
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(Color color, String text) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          text,
          style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
        ),
      ],
    );
  }

  String _getDayLabel(String date) {
    final now = DateTime.now();
    final dateTime = DateTime.parse(date);

    if (dateTime.year == now.year &&
        dateTime.month == now.month &&
        dateTime.day == now.day) {
      return 'Today';
    } else if (dateTime.year == now.year &&
        dateTime.month == now.month &&
        dateTime.day == now.day - 1) {
      return 'Yesterday';
    } else {
      const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      return days[dateTime.weekday - 1];
    }
  }

  IconData _getWeatherIcon(int code) {
    if (code == 0) return Icons.wb_sunny;
    if (code >= 80) return Icons.umbrella;
    if (code >= 60) return Icons.grain;
    if (code >= 50) return Icons.cloud;
    if (code >= 2) return Icons.cloud_outlined;
    return Icons.wb_sunny_outlined;
  }

  Color _getWeatherIconColor(int code) {
    if (code == 0) return const Color(0xFFFBBF24);
    if (code >= 80) return const Color(0xFF3B82F6);
    if (code >= 2) return const Color(0xFF9CA3AF);
    return const Color(0xFFFBBF24);
  }

  String _getWeatherCondition(int code) {
    if (code == 0) return 'Sunny';
    if (code >= 80) return 'Rainy';
    if (code >= 60) return 'Drizzle';
    if (code == 3) return 'Cloudy';
    if (code == 2) return 'Partly Cloudy';
    return 'Clear';
  }

  Map<String, dynamic> _getCampingSuitability(double precipitation) {
    if (precipitation < 30) {
      return {'text': 'Excellent', 'color': const Color(0xFF10B981)};
    } else if (precipitation < 60) {
      return {'text': 'Good', 'color': const Color(0xFFF59E0B)};
    } else {
      return {'text': 'Not Ideal', 'color': const Color(0xFFDC2626)};
    }
  }
}
