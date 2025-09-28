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

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  // Fetch weather data for the week
  Future<void> fetchData() async {
    final url = Uri.parse(
        'https://api.open-meteo.com/v1/forecast?latitude=7.8731&longitude=80.7718&daily=temperature_2m_max,weathercode&timezone=auto');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        setState(() {
          data = jsonData;
          dailyTemperature = data!['daily']?['temperature_2m_max'];
          dailyWeatherCode = data!['daily']?['weathercode'];
          dailyDates = data!['daily']?['time'];
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

  // Get the corresponding weather icon based on the weather code
  String getWeatherIcon(int weathercode) {
    switch (weathercode) {
      case 0:
        return 'assets/icons/clear_sky.png';
      case 1:
      case 2:
      case 3:
        return 'assets/images/clouds.png';
      case 45:
      case 48:
        return 'assets/icons/fog.png';
      case 51:
      case 53:
      case 55:
        return 'assets/icons/drizzle.png';
      case 61:
      case 63:
      case 65:
        return 'assets/images/rainy-7.svg';
      case 80:
      case 81:
      case 82:
        return 'assets/images/rainy-6.svg';
      case 95:
      case 96:
      case 99:
        return 'assets/icons/thunderstorm.png';
      default:
        return 'assets/images/cloudy-day-1.svg';
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

          // List of weather
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.only(top: 20),
              itemCount: dailyDates?.length ?? 0,
              itemBuilder: (context, index) {
                String day = DateFormat('EEE')
                    .format(DateTime.parse(dailyDates![index]));
                String description =
                    getWeatherDescription(dailyWeatherCode![index]);
                String temp = "${dailyTemperature![index].round()}°C";
                String iconPath = getWeatherIcon(dailyWeatherCode![index]);

                return Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          day,
                          style: GoogleFonts.openSans(
                            fontSize: 20,
                            color: Colors.white,
                          ),
                        ),
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
}
