import "package:flutter/material.dart";
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Variables
  Map<String, dynamic>? data;
  List<dynamic>? hourlyTimes;
  List<dynamic>? hourlyTemperatures;
  List<dynamic>? hourlyHumidities;
  String? timezone;
  String? greetings;
  String? formattedDate;
  String? formattedTime;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  /// Fetch Weather Data
  void fetchData() async {
    Uri url = Uri.parse(
        'https://api.open-meteo.com/v1/forecast?latitude=37.7749&longitude=-122.4194&hourly=temperature_2m,relative_humidity_2m&current_weather=true&timezone=GMT');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      setState(() {
        data = json.decode(response.body);
        hourlyTimes = data!['hourly']['time'].sublist(0, 24);
        hourlyTemperatures = data!['hourly']['temperature_2m'].sublist(0, 24);
        hourlyHumidities = data!['hourly']['relative_humidity_2m'].sublist(0, 24);
        timezone = data!['timezone'];

        // formatted date and time
        DateTime currentTime = DateTime.parse(data!['current_weather']['time']);
        int currentHour = currentTime.hour;

        if (currentHour < 12) {
          greetings = 'Good Morning!';
        } else if (currentHour < 17) {
          greetings = 'Good Afternoon!';
        } else {
          greetings = 'Good Evening!';
        }

        formattedDate = DateFormat('EEEE, MMM d, y').format(currentTime);
        formattedTime = DateFormat('h:mm a').format(currentTime);
      });
    } else {
      print('Error: ${response.statusCode}');
    }
  }

  /// Function to create gradient text
  Widget gradientText(String text, double fontSize, FontWeight fontWeight) {
    return ShaderMask(
      shaderCallback: (bounds) => const LinearGradient(
        colors: [Color(0xFFFFA500), Color(0xFF8A2BE2)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(bounds),
      child: Text(
        text,
        style: GoogleFonts.openSans(
          fontSize: fontSize,
          fontWeight: fontWeight,
          color: Colors.white,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFFFFA500), // Orange
              const Color(0xFF8A2BE2).withOpacity(0.6), // Purple
              const Color(0xFF000000), // Black
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.only(top: 60.0, right: 16.0, left: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Timezone, greet and more icon in a row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Timezone and greet
                  RichText(
                    text: TextSpan(
                      style: GoogleFonts.openSans(height: 1.1),
                      children: <TextSpan>[
                        TextSpan(
                          text: '${timezone ?? ""}\n',
                          style: TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.w100,
                            color: const Color(0xFFFFFFFF).withOpacity(0.7),
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

                  // more icon
                  Container(
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
                ],
              ),

              // Weather image
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Container(
                  height: 300,
                  width: 300,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage("assets/images/sunny.png"),
                    ),
                  ),
                ),
              ),

              // temperature, humidity, date and time
              if (data != null)
                Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      style: GoogleFonts.openSans(height: 1.3),
                      children: <TextSpan>[
                        TextSpan(
                          text: '${data!['current_weather']['temperature']}°C\n',
                          style: TextStyle(
                            fontSize: 75.0,
                            fontWeight: FontWeight.w100,
                            color: const Color(0xFFFFFFFF).withOpacity(0.7),
                          ),
                        ),
                        TextSpan(
                          text:
                              'Humidity ${hourlyHumidities != null ? hourlyHumidities![0].toString() : "--"}%\n',
                          style: const TextStyle(
                            fontSize: 20.0,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFFFFFFFF),
                          ),
                        ),
                        TextSpan(
                          text: '${formattedDate ?? ""} · ${formattedTime ?? ""}',
                          style: TextStyle(
                            fontSize: 14.0,
                            color: const Color(0xFFFFFFFF).withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              // hourly forecast
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    gradientText("Hourly Forecast", 20.0, FontWeight.bold),
                    Container(
                      padding: const EdgeInsets.all(2.0),
                      height: 30.0,
                      width: 30.0,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFFFFF),
                        borderRadius: BorderRadius.circular(100.0),
                      ),
                      child: const Icon(
                        Icons.keyboard_arrow_left_outlined,
                        color: Color(0xFF000000),
                      ),
                    ),
                  ],
                ),
              ),

              // hourly list
              if (data != null)
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(0.0),
                    itemCount: hourlyTimes?.length ?? 0,
                    itemBuilder: (context, index) {
                      return Container(
                        padding: const EdgeInsets.only(bottom: 12.0, top: 5.0),
                        width: MediaQuery.of(context).size.width,
                        decoration: const BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              width: 0.4,
                              color: Color(0xFFFFFFFF),
                            ),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // time
                            Text(
                              DateFormat('h a')
                                  .format(DateTime.parse(hourlyTimes![index])),
                              style: GoogleFonts.openSans(
                                fontSize: 20.0,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFFFFFFFF),
                              ),
                            ),
                            // humidity
                            Text(
                              '${hourlyHumidities![index]}%',
                              style: GoogleFonts.openSans(
                                fontSize: 16.0,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFFFFFFFF),
                              ),
                            ),
                            // temperature
                            Text(
                              '${hourlyTemperatures![index]}°C',
                              style: GoogleFonts.openSans(
                                fontSize: 24.0,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFFFFFFFF),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                )
              else
                const Expanded(
                  child: Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
