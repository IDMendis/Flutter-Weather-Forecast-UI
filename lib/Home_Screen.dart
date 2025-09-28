import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
// Removed: import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Map<String, dynamic>? data;
  String? currentCity;
  final String apiKey = "YOUR_OPENWEATHER_API_KEY"; // <-- replace with your actual API key

  // Text controller for the search input
  late final TextEditingController _searchController;
  List<dynamic> _citySuggestions = []; // To store suggestions from GeoCoding API
  bool _isSearching = false; // To show/hide suggestions

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _loadLastCity(); // load saved city
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Load last saved city from local storage
  Future<void> _loadLastCity() async {
    final prefs = await SharedPreferences.getInstance();
    final savedCity = prefs.getString("last_city");
    if (savedCity != null && savedCity.isNotEmpty) {
      setState(() {
        currentCity = savedCity;
        _searchController.text = savedCity;
      });
      await fetchWeatherByCity(savedCity);
    } else {
      await _getCurrentLocation(); // fallback: use GPS
    }
  }

  /// Save city in SharedPreferences
  Future<void> _saveCity(String city) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("last_city", city);
  }

  /// Determine position with permission checks
  Future<Position> _determinePosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Optionally open settings
      throw Exception('Location services are disabled.');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception(
          'Location permissions are permanently denied, cannot request.');
    }

    return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
  }

  /// Get location from GPS (with permission handling)
  Future<void> _getCurrentLocation() async {
    setState(() {
      data = null; // Clear previous weather data while fetching new
      currentCity = "Fetching location...";
    });
    try {
      final position = await _determinePosition();

      final placemarks = await placemarkFromCoordinates(
          position.latitude, position.longitude);

      if (placemarks.isNotEmpty) {
        final city = placemarks.first.locality ?? placemarks.first.subAdministrativeArea ?? "Unknown";
        setState(() {
          currentCity = city;
          _searchController.text = city; // Update search bar with current location
        });
        await _saveCity(city);
        await fetchWeatherByCoords(position.latitude, position.longitude);
      }
    } catch (e) {
      // handle permission or GPS errors gracefully
      debugPrint('Error getting location: $e');
      if (mounted) {
        setState(() {
          currentCity = "Location unavailable";
          data = null; // Clear data on error
        });
      }
      // Show a SnackBar or AlertDialog to the user
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not get current location: ${e.toString()}')),
      );
    }
  }

  /// Fetch weather using city name
  Future<void> fetchWeatherByCity(String city) async {
    setState(() {
      data = null; // Clear previous weather data while fetching new
      currentCity = "Fetching weather for $city...";
    });
    try {
      final url =
          "https://api.openweathermap.org/data/2.5/weather?q=$city&appid=$apiKey&units=metric";
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        setState(() {
          data = json.decode(response.body);
          currentCity = data!['name']; // Update currentCity with actual name from API
        });
        await _saveCity(data!['name']);
      } else {
        debugPrint('Weather API error: ${response.statusCode} ${response.body}');
        if (mounted) {
          setState(() {
            currentCity = "Could not find weather for '$city'";
            data = null;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Could not find weather for "$city"')),
          );
        }
      }
    } catch (e) {
      debugPrint('fetchWeatherByCity error: $e');
      if (mounted) {
        setState(() {
          currentCity = "Error fetching weather";
          data = null;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error fetching weather: ${e.toString()}')),
        );
      }
    }
  }

  /// Fetch weather using coordinates
  Future<void> fetchWeatherByCoords(double lat, double lon) async {
    setState(() {
      data = null; // Clear previous weather data while fetching new
      currentCity = "Fetching weather...";
    });
    try {
      final url =
          "https://api.openweathermap.org/data/2.5/weather?lat=$lat&lon=$lon&appid=$apiKey&units=metric";
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        setState(() {
          data = json.decode(response.body);
          currentCity = data!['name']; // Update currentCity with actual name from API
        });
        await _saveCity(data!['name']);
      } else {
        debugPrint('Weather API error: ${response.statusCode} ${response.body}');
        if (mounted) {
          setState(() {
            currentCity = "Could not find weather for coordinates";
            data = null;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Could not find weather for the selected location')),
          );
        }
      }
    } catch (e) {
      debugPrint('fetchWeatherByCoords error: $e');
      if (mounted) {
        setState(() {
          currentCity = "Error fetching weather";
          data = null;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error fetching weather: ${e.toString()}')),
        );
      }
    }
  }

  /// Fetch city suggestions using OpenWeatherMap GeoCoding API
  Future<void> _searchSuggestions(String pattern) async {
    if (pattern.isEmpty) {
      setState(() {
        _citySuggestions = [];
        _isSearching = false;
      });
      return;
    }

    setState(() {
      _isSearching = true; // Indicate that suggestions are being fetched
    });

    try {
      final url = "http://api.openweathermap.org/geo/1.0/direct?q=$pattern&limit=5&appid=$apiKey";
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final List<dynamic> result = json.decode(response.body);
        setState(() {
          _citySuggestions = result;
        });
      } else {
        debugPrint('GeoCoding API error: ${response.statusCode} ${response.body}');
        setState(() {
          _citySuggestions = [];
        });
      }
    } catch (e) {
      debugPrint('GeoCoding search error: $e');
      setState(() {
        _citySuggestions = [];
      });
    } finally {
      setState(() {
        _isSearching = false; // Searching finished
      });
    }
  }

  /// Build the search bar with suggestions
  Widget buildSearchBar() {
    return Column(
      children: [
        TextField(
          controller: _searchController,
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.search),
            hintText: "Search city...",
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _searchController.clear();
                      setState(() {
                        _citySuggestions = [];
                      });
                    },
                  )
                : null,
          ),
          onChanged: (text) {
            _searchSuggestions(text);
          },
          onTap: () {
            setState(() {
              _isSearching = true; // Show suggestions when text field is tapped
            });
          },
          onSubmitted: (text) {
             if (text.isNotEmpty) {
               // If user submits without selecting, try to fetch weather for the typed city
               fetchWeatherByCity(text);
               setState(() {
                 _isSearching = false; // Hide suggestions after submission
               });
             }
          },
        ),
        if (_isSearching && _citySuggestions.isNotEmpty)
          Container(
            constraints: BoxConstraints(maxHeight: 200), // Limit height of suggestions
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(10),
                bottomRight: Radius.circular(10),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 2,
                  blurRadius: 5,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _citySuggestions.length,
              itemBuilder: (context, index) {
                final suggestion = _citySuggestions[index];
                final cityName = suggestion['name'];
                final stateName = suggestion['state'];
                final countryName = suggestion['country'];
                return ListTile(
                  title: Text(
                    cityName +
                        (stateName != null ? ", $stateName" : "") +
                        ", $countryName",
                  ),
                  onTap: () async {
                    _searchController.text = cityName; // Set the selected city
                    setState(() {
                      _isSearching = false; // Hide suggestions
                      _citySuggestions = []; // Clear suggestions
                    });
                    // Fetch weather using the coordinates of the selected city
                    await fetchWeatherByCoords(suggestion['lat'], suggestion['lon']);
                  },
                );
              },
            ),
          ),
        if (_isSearching && _citySuggestions.isEmpty && _searchController.text.isNotEmpty)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text('No suggestions found.'),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[100],
      appBar: AppBar(
        title: Text(
          "Weather App",
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.my_location),
            onPressed: _getCurrentLocation,
          )
        ],
      ),
      body: GestureDetector(
        onTap: () {
          // Hide keyboard and suggestions when tapping outside
          FocusScope.of(context).unfocus();
          setState(() {
            _isSearching = false;
          });
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              buildSearchBar(),
              const SizedBox(height: 20),
              // Display weather data or loading indicator
              if (data != null)
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          currentCity ?? "Unknown location",
                          style: GoogleFonts.poppins(
                              fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          "${data!['main']['temp'].round()}°C", // Round temperature
                          style: GoogleFonts.poppins(fontSize: 48),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          data!['weather'][0]['description'],
                          style: GoogleFonts.poppins(fontSize: 20),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          "Humidity: ${data!['main']['humidity']}%",
                          style: GoogleFonts.poppins(fontSize: 16),
                        ),
                        Text(
                          "Wind: ${data!['wind']['speed']} m/s",
                          style: GoogleFonts.poppins(fontSize: 16),
                        ),
                        if (data!['sys'] != null && data!['sys']['sunrise'] != null)
                          Text(
                            "Sunrise: ${DateFormat.Hm().format(DateTime.fromMillisecondsSinceEpoch(data!['sys']['sunrise'] * 1000, isUtc: true).toLocal())}",
                            style: GoogleFonts.poppins(fontSize: 16),
                          ),
                        if (data!['sys'] != null && data!['sys']['sunset'] != null)
                          Text(
                            "Sunset: ${DateFormat.Hm().format(DateTime.fromMillisecondsSinceEpoch(data!['sys']['sunset'] * 1000, isUtc: true).toLocal())}",
                            style: GoogleFonts.poppins(fontSize: 16),
                          ),
                      ],
                    ),
                  ),
                )
              else if (currentCity != null && currentCity!.contains("Fetching"))
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const CircularProgressIndicator(),
                        const SizedBox(height: 10),
                        Text(currentCity!, style: GoogleFonts.poppins()),
                      ],
                    ),
                  ),
                )
              else
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.cloud_outlined, size: 80, color: Colors.grey),
                        const SizedBox(height: 10),
                        Text(
                          currentCity ?? "Enter a city or use GPS",
                          style: GoogleFonts.poppins(fontSize: 18, color: Colors.grey),
                          textAlign: TextAlign.center,
                        ),
                      ],
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