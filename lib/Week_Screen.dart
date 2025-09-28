import 'package:flutter/material.dart'; 
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:flutter_svg/flutter_svg.dart';


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
      case 71:
      case 73:
      case 75:
        return 'Snow';
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
  Widget buildWeatherIcon(int code) {
  String path = getWeatherIcon(code);

  if (path.endsWith('.svg')) {
    return SvgPicture.asset(
      path,
      width: 50,
      height: 50,
    );
  } else {
    return Image.asset(
      path,
      width: 50,
      height: 50,
    );
  }
}


  // Get weather icon asset path
  String getWeatherIcon(int weathercode) {
    if (weathercode == 0) return 'assets/icons/day.svg';
    if (weathercode >= 1 && weathercode <= 3) return 'assets/icons/cloudy.svg';
    if (weathercode == 45 || weathercode == 48) return 'assets/icons/fog_8047121.png';
    if ((weathercode >= 51 && weathercode <= 67) ||
        (weathercode >= 80 && weathercode <= 82)) {
      return 'assets/icons/rainy-6.svg';
    }
    if (weathercode >= 71 && weathercode <= 77) return 'assets/icons/snowy-6.svg';
    if (weathercode >= 95 && weathercode <= 99) return 'assets/icons/thunder.svg';
    return 'assets/icons/cloudy.svg'; // default
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
                String iconPath =
                    getWeatherIcon(dailyWeatherCode![index]);

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Row(
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
                      // Weather description + icon
                      Row(
                        children: [
                          Text(
                            description,
                            style: GoogleFonts.openSans(
                              fontSize: 16,
                              color: Colors.white70,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Image.asset(
                            iconPath,
                            height: 28,
                            width: 28,
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
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
