import "package:flutter/material.dart";
import 'package:google_fonts/google_fonts.dart';
// ignore: depend_on_referenced_packages
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'Week_Screen.dart';

// Your API keys
final String geoApiKey = "fdda7ec20d2f4f60a191accf4a00df16";
final String weatherApiKey = "af32a05a4e6743cb8560438c6a345cb1";

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Map<String, dynamic>? data; // current weather
  String? greetings;
  String? formattedDate;
  String? formattedTime;

  List<dynamic>? hourlyTemperatures;
  List<dynamic>? hourlyTimes;
  List<dynamic>? hourlyHumidities;

  TextEditingController searchController = TextEditingController();
  String? currentCity;
  bool isNightTheme = false;

   String getWeatherGif(String condition) {
  condition = condition.toLowerCase();

  if (condition.contains("cloud")) {
    return "assets/images/clouds.png";
  } else if (condition.contains("rain")) {
    return "assets/images/rainy-day.png";
  } else if (condition.contains("snow")) {
    return "assets/images/snowflake.png";
  } else if (condition.contains("thunder")) {
    return "assets/images/Fallen tree and wind.gif";
  } else if (condition.contains("sun") || condition.contains("clear")) {
    return "assets/images/sunny.png";
  } else {
    return "assets/images/Fallen tree and wind.gif"; // fallback
  }
}


  @override
  void initState() {
    super.initState();
    getCurrentCity();
  }

  /// Fetch current city using ipgeolocation.io
  Future<void> getCurrentCity() async {
    final url = Uri.parse("https://api.ipgeolocation.io/ipgeo?apiKey=$geoApiKey");
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final result = json.decode(response.body);
      setState(() {
        currentCity = result["city"];
      });
      fetchWeatherByCity(currentCity!);
    } else {
      debugPrint("Error fetching location: ${response.statusCode}");
    }
  }

  /// Fetch current + hourly forecast
  Future<void> fetchWeatherByCity(String city) async {
    final weatherUrl = Uri.parse(
        "https://api.openweathermap.org/data/2.5/weather?q=$city&appid=$weatherApiKey&units=metric");

    final forecastUrl = Uri.parse(
        "https://api.openweathermap.org/data/2.5/forecast?q=$city&appid=$weatherApiKey&units=metric");

    final weatherRes = await http.get(weatherUrl);
    final forecastRes = await http.get(forecastUrl);

    if (weatherRes.statusCode == 200 && forecastRes.statusCode == 200) {
      final weatherResult = json.decode(weatherRes.body);
      final forecastResult = json.decode(forecastRes.body);

      // greeting logic
      int currentHour = DateTime.now().hour;
      if (currentHour < 12) {
        greetings = 'Good Morning!';
      } else if (currentHour < 17) {
        greetings = 'Good Afternoon!';
      } else {
        greetings = 'Good Evening!';
      }

        // night/day theme logic
      final sunrise = DateTime.fromMillisecondsSinceEpoch(
          weatherResult["sys"]["sunrise"] * 1000,
          isUtc: true).toLocal();
      final sunset = DateTime.fromMillisecondsSinceEpoch(
          weatherResult["sys"]["sunset"] * 1000,
          isUtc: true).toLocal();
      final now = DateTime.now();
      isNightTheme = now.isBefore(sunrise) || now.isAfter(sunset);

      setState(() {
        data = weatherResult;
        formattedDate = DateFormat('EEEE, MMM d, y').format(DateTime.now());
        formattedTime = DateFormat('h:mm a').format(DateTime.now());

        // hourly forecast (next 8 = 24 hrs)
        hourlyTimes = forecastResult["list"]
            .take(8)
            .map((e) => e["dt_txt"])
            .toList();
        hourlyTemperatures = forecastResult["list"]
            .take(8)
            .map((e) => e["main"]["temp"])
            .toList();
        hourlyHumidities = forecastResult["list"]
            .take(8)
            .map((e) => e["main"]["humidity"])
            .toList();
      });
    } else {
      debugPrint("Error fetching weather: "
          "${weatherRes.statusCode}, ${forecastRes.statusCode}");
    }
  }

  @override
  Widget build(BuildContext context) {
    final backgroundGradient = isNightTheme
        ? [Colors.indigo[900]!, Colors.black] // night theme
        : [Colors.orange, Colors.blueAccent]; // day theme

    return Scaffold(
      body: data == null
          ? Container(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: backgroundGradient,
                ),
              ),
              child: const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            )
          : Container(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: backgroundGradient,
                ),
              ),
              child: Padding(
                padding:
                    const EdgeInsets.only(top: 60.0, right: 16.0, left: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // City name, greeting & more btn
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        RichText(
                          text: TextSpan(
                            style: GoogleFonts.openSans(height: 1.1),
                            children: <TextSpan>[
                              TextSpan(
                                text: '${currentCity ?? ""}\n',
                                style: TextStyle(
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.w100,
                                  color:
                                      const Color(0xFFFFFFFF).withOpacity(0.7),
                                ),
                              ),
                              TextSpan(
                                text: greetings ?? "",
                                style: const TextStyle(
                                  fontSize: 20.0,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFFFFFFFF),
                                ),
                              ),
                            ],
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => const WeekScreen(),
                              ),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.all(2.0),
                            height: 40.0,
                            width: 40.0,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(100.0),
                              border: Border.all(
                                width: 0.4,
                                color: const Color(0xFFFFFFFF),
                              ),
                            ),
                            child: const Icon(
                              Icons.more_vert_outlined,
                              color: Color(0xFFFFFFFF),
                            ),
                          ),
                        ),
                      ],
                    ),

                    // Search bar
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 0, vertical: 12),
                      child: TextField(
                        controller: searchController,
                        decoration: InputDecoration(
                          hintText: "Enter city...",
                          prefixIcon:
                              const Icon(Icons.search, color: Colors.white),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.2),
                          hintStyle: const TextStyle(color: Colors.white70),
                        ),
                        style: const TextStyle(color: Colors.white),
                        onSubmitted: (value) {
                          if (value.isNotEmpty) {
                            fetchWeatherByCity(value);
                            setState(() => currentCity = value);
                          }
                        },
                      ),
                    ),

                    // Weather image
                    // Padding(
                    //   padding: const EdgeInsets.all(16.0),
                    //   child: Container(
                    //     height: 200,
                    //     width: 200,
                    //     decoration: const BoxDecoration(
                    //       image: DecorationImage(
                    //         image: AssetImage("assets/images/sunny.png"),
                    //       ),
                    //     ),
                    //   ),
                    // ),


                    // Weather GIF (instead of static icon)
Padding(
  padding: const EdgeInsets.all(16.0),
  child: Container(
    height: 200,
    width: 200,
    decoration: BoxDecoration(
      image: DecorationImage(
        image: AssetImage(
          getWeatherGif(data!['weather'][0]['description']),
        ),
        fit: BoxFit.contain,
      ),
    ),
  ),
),


                    // temp, humidity, date/time
                    RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        style: GoogleFonts.openSans(height: 1.3),
                        children: <TextSpan>[
                          TextSpan(
                            text: '${currentCity ?? "Unknown City"}\n',
                            style: const TextStyle(
                              fontSize: 28.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          TextSpan(
                            text: '${data!['main']['temp']}°C\n',
                            style: TextStyle(
                              fontSize: 75.0,
                              fontWeight: FontWeight.w100,
                              color: const Color(0xFFFFFFFF).withOpacity(0.7),
                            ),
                          ),
                          TextSpan(
                            text: 'Humidity ${data!['main']['humidity']}%\n',
                            style: const TextStyle(
                              fontSize: 20.0,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFFFFFFFF),
                            ),
                          ),
                          TextSpan(
                            text:
                                '${formattedDate ?? ""} · ${formattedTime ?? ""}\n',
                            style: TextStyle(
                              fontSize: 14.0,
                              color:
                                  const Color(0xFFFFFFFF).withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // ⬇hourly forecast scroll
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        itemCount: hourlyTimes?.length ?? 0,
                        itemBuilder: (context, index) {
                          return ListTile(
                            leading: Text(
                              DateFormat('h a')
                                  .format(DateTime.parse(hourlyTimes![index])),
                              style: GoogleFonts.poppins(
                                  color: Colors.white, fontSize: 16),
                            ),
                            title: Text( // Removed the Row here, as the image is for humidity
                              "${hourlyTemperatures![index]}°C",
                              style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500),
                            ),

                            trailing: Row( // Use a Row for the trailing widget to place text and image
                              mainAxisSize: MainAxisSize.min, // Keep the row compact
                              children: [
                                Text(
                                  "Humidity: ${hourlyHumidities![index]}%",
                                  style: GoogleFonts.poppins(
                                      color: Colors.white70, fontSize: 14),
                                ),
                                SizedBox(width: 4), // Add some spacing
                                Image.asset(
                                  'assets/images/Humidity-icon.png',
                                  width: 20, // Adjust width as needed
                                  height: 20, // Adjust height as needed
                                  color: Colors.white70, // Optional: if you want to tint the image
                                ),
                              ],
                            ),

                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
