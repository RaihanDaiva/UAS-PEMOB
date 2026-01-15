import 'package:flutter/material.dart';

class WeatherForecastPage extends StatelessWidget {
  final Map<String, dynamic> campsite;

  WeatherForecastPage({super.key, required this.campsite});

  final List<Map<String, dynamic>> weatherData = [
    {'day': 'Yesterday', 'temp': 26, 'condition': 'Partly Cloudy', 'precip': 40, 'wind': 12},
    {'day': 'Today', 'temp': 28, 'condition': 'Sunny', 'precip': 10, 'wind': 8},
    {'day': 'Thu', 'temp': 27, 'condition': 'Partly Cloudy', 'precip': 20, 'wind': 10},
    {'day': 'Fri', 'temp': 25, 'condition': 'Rainy', 'precip': 80, 'wind': 15},
  ];

  Color suitabilityColor(int precip) {
    if (precip < 30) return Colors.green;
    if (precip < 60) return Colors.orange;
    return Colors.red;
  }

  String suitabilityText(int precip) {
    if (precip < 30) return 'Excellent';
    if (precip < 60) return 'Good';
    return 'Not Ideal';
  }

  @override
  Widget build(BuildContext context) {
    final today = weatherData[1];

    return Scaffold(
      backgroundColor: Colors.blue.shade50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Weather Forecast'),
            Text(
              campsite['name'],
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          /// Today Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Colors.blue, Colors.lightBlue],
              ),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Today’s Weather', style: TextStyle(color: Colors.white70)),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${today['temp']}°',
                          style: const TextStyle(fontSize: 48, color: Colors.white),
                        ),
                        Text(
                          today['condition'],
                          style: const TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                    const Icon(Icons.wb_sunny, size: 64, color: Colors.white),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          /// Forecast List
          const Text('Forecast', style: TextStyle(fontSize: 18)),
          const SizedBox(height: 12),
          ...weatherData.map((day) {
            return Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: ListTile(
                title: Text(day['day']),
                subtitle: Text(day['condition']),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('${day['temp']}°C'),
                    Container(
                      margin: const EdgeInsets.only(top: 4),
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: suitabilityColor(day['precip']),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        suitabilityText(day['precip']),
                        style: const TextStyle(color: Colors.white, fontSize: 10),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }
}
