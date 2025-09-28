import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

class WeekScreen extends StatefulWidget {
  const WeekScreen({super.key});

  @override
  State<WeekScreen> createState() => _WeekScreenState();
}

class _WeekScreenState extends State<WeekScreen> {
  // Variables
  Map<String, dynamic>? data;
  List<dynamic>? dailyTemperature;
  List<dynamic>? dailyWeatherCode;
  List<dynamic>? dailyDates;

  // For additional data (e.g., wind, sunrise, sunset)
  double? windSpeed;
  String? sunriseTime;
  String? sunsetTime;
  String? rainDescription;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  String getWeatherIcon(int code) {
    if (code == 0) {
      return "assets/images/sunny.png"; // ☀️
    } else if (code == 1 || code == 2) {
      return "assets/images/partly_cloudy.png"; // ⛅
    } else if (code == 3) {
      return "assets/images/clouds.png"; // ☁️
    } else if (code == 61 || code == 63 || code == 65) {
      return "assets/images/rainy-day.png"; // 🌧️
    } else if (code == 71 || code == 73 || code == 75) {
      return "assets/images/snowy.png"; // ❄️
    } else if (code == 95) {
      return "assets/images/thunder.png"; // ⛈️
    }
    return "assets/images/rainy-day.png"; // fallback icon
  }

  // Fetch weather data for the week
  Future<void> fetchData() async {
    final url = Uri.parse(
        'https://api.open-meteo.com/v1/forecast?latitude=7.8731&longitude=80.7718&daily=temperature_2m_max,weathercode,wind_speed_10m_max,sunrise,sunset&timezone=auto');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        setState(() {
          data = jsonData;
          dailyTemperature = data!['daily']?['temperature_2m_max'];
          dailyWeatherCode = data!['daily']?['weathercode'];
          dailyDates = data!['daily']?['time'];

          windSpeed = data!['daily']?['wind_speed_10m_max'][0];
          sunriseTime = data!['daily']?['sunrise'][0];
          sunsetTime = data!['daily']?['sunset'][0];
          rainDescription = "Rain possible overnight"; // Placeholder
        });
      } else {
        print('Error: ${response.statusCode}');
      }
    } catch (e) {
      print('Exception: $e');
    }
  }

  // Get the weather description based on the weather code
  String getWeatherDescription(int weathercode) {
    switch (weathercode) {
      case 0:
        return 'Clear Sky';
      case 1:
      case 2:
      case 3:
        return 'Partly Cloudy';
      case 45:
      case 48:
        return 'Fog';
      case 51:
      case 53:
      case 55:
        return 'Drizzle';
      case 61:
      case 63:
      case 65:
        return 'Showers';
      case 80:
      case 81:
      case 82:
        return 'Rain Showers';
      case 95:
      case 96:
      case 99:
        return 'Thunderstorm';
      default:
        return 'Unknown';
    }
  }

  // Function to navigate back
  void navigateBackFunction(BuildContext context) {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: data == null
          ? _buildLoadingScreen()
          : _buildWeatherScreen(context),
    );
  }

  Widget _buildLoadingScreen() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF4B0082), Color(0xFF9370DB), Color(0xFF000000)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: const Center(
        child: CircularProgressIndicator(color: Colors.white),
      ),
    );
  }

  Widget _buildWeatherScreen(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF4B0082), Color(0xFF9370DB), Color(0xFF000000)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      padding: const EdgeInsets.only(top: 60, left: 16, right: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Back Button + Icon
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  GestureDetector(
                    onTap: () => navigateBackFunction(context),
                    child: Container(
                      padding: const EdgeInsets.all(2.0),
                      height: 30,
                      width: 30,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(100.0),
                      ),
                      child: const Icon(
                        Icons.keyboard_arrow_left_outlined,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Back',
                    style: GoogleFonts.openSans(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              Container(
                height: 50,
                width: 50,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/images/clouds.png'),
                  ),
                ),
              ),
            ],
          ),

          // Calendar + Title
          Padding(
            padding: const EdgeInsets.only(top: 20),
            child: Row(
              children: [
                const Icon(Icons.calendar_month_rounded,
                    color: Colors.white, size: 30),
                const SizedBox(width: 10),
                Text(
                  'This Week',
                  style: GoogleFonts.openSans(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),

          // Additional widgets (Wind, Sunrise, Sunset)
          Padding(
            padding: const EdgeInsets.only(top: 20),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildInfoCard(Icons.air, "Wind", "$windSpeed km/h"),
                  const SizedBox(width: 5),
                  _buildInfoCard(Icons.wb_sunny, "Sunrise", sunriseTime ?? "N/A"),
                  const SizedBox(width: 5),
                  _buildInfoCard(Icons.nightlight_round, "Sunset", sunsetTime ?? "N/A"),
                ],
              ),
            ),
          ),

          // Rain Coming Widget
          Padding(
            padding: const EdgeInsets.only(top: 20),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF4B0082).withOpacity(0.7),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Rain Coming",
                    style: GoogleFonts.openSans(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    rainDescription ?? "No rain expected",
                    style: GoogleFonts.openSans(
                      fontSize: 14,
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: List.generate(4, (index) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 4),
                        child: CircleAvatar(
                          radius: 5,
                          backgroundColor:
                              index == 3 ? Colors.white : Colors.grey,
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),
          ),

          // List of weather for the week
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.only(top: 20),
              itemCount: dailyDates?.length ?? 0,
              itemBuilder: (context, index) {
                String day =
                    DateFormat('EEE').format(DateTime.parse(dailyDates![index]));
                String description =
                    getWeatherDescription(dailyWeatherCode![index]);
                String temp = "${dailyTemperature![index].round()}°C";

                // Pick icon based on description/code
                String iconPath = getWeatherIcon(dailyWeatherCode![index]);

                return Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Day
                        Text(
                          day,
                          style: GoogleFonts.openSans(
                            fontSize: 20,
                            color: Colors.white,
                          ),
                        ),

                        // Weather icon + description
                        Row(
                          children: [
                            Image.asset(
                              iconPath,
                              width: 30,
                              height: 30,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              description,
                              style: GoogleFonts.openSans(
                                fontSize: 16,
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),

                        // Temperature
                        Text(
                          temp,
                          style: GoogleFonts.openSans(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    const Divider(
                      color: Colors.white70,
                      thickness: 0.5,
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  //  Custom widget for the info cards
  Widget _buildInfoCard(IconData icon, String title, String value) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF4B0082).withOpacity(0.7),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, size: 40, color: Colors.white),
          const SizedBox(height: 8),
          Text(
            title,
            style: GoogleFonts.openSans(
              fontSize: 14,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.openSans(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
