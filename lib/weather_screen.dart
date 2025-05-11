import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:Weatherly/api_key.dart';
import 'package:weather_icons/weather_icons.dart';
import 'Additional_item.dart';
import 'hourly_forecast_item.dart';
import 'dart:async';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

DateTime now = DateTime.now();
int hour = now.hour;
int minute = now.minute;
int year = now.year;
int month = now.month;
int day = now.day;

class _WeatherScreenState extends State<WeatherScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<String> searchResults = [];
  bool isSearching = false;
  Timer? _debounce;
  String cityName = 'Bardhaman';
  Map<String, dynamic>? weatherData;

  @override
  void initState() {
    super.initState();
    _fetchWeatherData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> _fetchWeatherData() async {
    try {
      final data = await getCurrentWeather();
      if (mounted) {
        setState(() {
          weatherData = data;
        });
      }
    } catch (e) {
      print('Error fetching weather: $e');
    }
  }

  Future<List<String>> searchCities(String query) async {
    if (query.isEmpty) return [];

    try {
      final res = await http.get(
        Uri.parse(
          'https://api.openweathermap.org/geo/1.0/direct?q=$query&limit=5&appid=$apiKey',
        ),
      );

      if (res.statusCode == 200) {
        final List<dynamic> data = jsonDecode(res.body);
        return data
            .map((city) => '${city['name']}, ${city['country']}')
            .toList();
      }
      return [];
    } catch (e) {
      print('Error searching cities: $e');
      return [];
    }
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () async {
      if (query.isNotEmpty) {
        final results = await searchCities(query);
        if (mounted) {
          setState(() {
            searchResults = results;
            isSearching = true;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            searchResults = [];
            isSearching = false;
          });
        }
      }
    });
  }

  Future<Map<String, dynamic>> getCurrentWeather() async {
    try {
      final res = await http.get(
        Uri.parse(
          'https://api.openweathermap.org/data/2.5/forecast?q=$cityName&APPID=$apiKey',
        ),
      );
      final data = jsonDecode(res.body);
      if (data['cod'] != '200') {
        throw 'An unexpected error occurred';
      }
      return data;
    } catch (e) {
      throw e.toString();
    }
  }

  // Function to convert Kelvin to Celsius
  String toCelsius(double kelvin) {
    return '${(kelvin - 273.15).toStringAsFixed(1)} °C';
  }

  String getBackgroundImage(String currentSky, int hour) {
    String sky = currentSky.toLowerCase();

    if (sky == 'clear') {
      if (hour >= 4 && hour < 13) {
        return 'https://res.cloudinary.com/deuhpyrku/image/upload/v1743234374/output-onlinegiftools_pzgyt0.gif'; // Daytime clear
      }
      if (hour >= 13 && hour < 19) {
        return 'https://res.cloudinary.com/deuhpyrku/image/upload/v1743112211/bg66_jcxt8k.jpg'; // Evening clear
      } else {
        return 'https://res.cloudinary.com/deuhpyrku/image/upload/v1743112216/bg17_iwwubp.jpg'; // Nighttime clear
      }
    } else if (sky == 'clouds') {
      if (hour >= 4 && hour < 12) {
        return 'https://res.cloudinary.com/deuhpyrku/image/upload/v1743112251/bg3_lf8jx5.gif'; // Daytime clouds
      }
      if (hour >= 12 && hour < 19) {
        return 'https://res.cloudinary.com/deuhpyrku/image/upload/v1743112231/bg15_beyowc.gif'; // Evening clouds
      } else {
        return 'https://res.cloudinary.com/deuhpyrku/image/upload/v1743113029/bg2_zbtzjz.jpg'; // Nighttime clouds
      }
    } else if (sky == 'rain') {
      if (hour >= 9 && hour < 15) {
        return 'https://res.cloudinary.com/deuhpyrku/image/upload/v1743112218/bg11_inbpqa.gif';
      } else {
        return 'https://res.cloudinary.com/deuhpyrku/image/upload/v1743112223/bg6_eosnai.gif';
      }
    } else if (sky == 'snow') {
      return 'https://res.cloudinary.com/deuhpyrku/image/upload/v1743112244/bg17_fxtjdx.gif';
    } else if (sky == 'fog') {
      return 'https://res.cloudinary.com/deuhpyrku/image/upload/v1743112211/bg63_s9r9bg.jpg';
    } else {
      return 'https://res.cloudinary.com/deuhpyrku/image/upload/v1743112211/bg14_hq7sbj.jpg';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Weatherly',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
            letterSpacing: 1.2,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue.shade800, Colors.deepPurple.shade900],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
          ),
        ),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(15.0), // Adjust the height as needed
          child: Padding(
            padding: EdgeInsets.only(bottom: 8.0),
            child: Text(
              '☁️ - by ranojit ☀️',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ),
    actions: [
    IconButton(
    onPressed: () async {
    try {
    setState(() {
    weatherData = null;  // Clear old data before refreshing
    });
    await _fetchWeatherData();  // Fetch new weather data
    setState(() {});  // Update UI
    print("Weather data refreshed!");
    } catch (e) {
    print("Failed to refresh: $e");
    }
    },
    icon: const Icon(Icons.refresh, color: Colors.white),
    ),
    ],
      ),


    // Body of the App
      body:
          weatherData == null
              ? const Center(child: CircularProgressIndicator())
              : Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage(
                      getBackgroundImage(
                        weatherData!['list'][0]['weather'][0]['main'],
                        hour,
                      ),
                    ),
                    fit: BoxFit.cover,
                  ),
                ),
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          cityName,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 15,),
                        // City Search Box
                        Row(
                          children: [
                            const Icon(Icons.location_on),
                            const SizedBox(width: 5),
                            Expanded(
                              child: TextField(
                                controller: _searchController,
                                decoration: InputDecoration(
                                  hintText: 'Search for a city...',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  filled: true,
                                  fillColor: Colors.white.withOpacity(0.2),
                                  prefixIcon: const Icon(Icons.search),
                                  suffixIcon:
                                      _searchController.text.isNotEmpty
                                          ? IconButton(
                                            icon: const Icon(Icons.clear),
                                            onPressed: () {
                                              _searchController.clear();
                                              setState(() {
                                                searchResults = [];
                                                isSearching = false;
                                              });
                                            },
                                          )
                                          : null,
                                ),
                                onChanged: _onSearchChanged,
                                onSubmitted: (value) {
                                  if (value.isNotEmpty) {
                                    setState(() {
                                      cityName = value.split(',')[0];
                                      searchResults = [];
                                      isSearching = false;
                                    });
                                    _searchController.clear();
                                    _fetchWeatherData();
                                  }
                                },
                              ),
                            ),
                          ],
                        ),

                        if (isSearching && searchResults.isNotEmpty)
                          Container(
                            constraints: BoxConstraints(
                              maxHeight:
                                  MediaQuery.of(context).size.height * 0.3,
                            ),
                            margin: const EdgeInsets.only(top: 8),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ListView.builder(
                              shrinkWrap: true,
                              itemCount: searchResults.length,
                              itemBuilder: (context, index) {
                                return ListTile(
                                  title: Text(
                                    searchResults[index],
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                  onTap: () {
                                    setState(() {
                                      cityName =
                                          searchResults[index].split(',')[0];
                                      searchResults = [];
                                      isSearching = false;
                                    });
                                    _searchController.clear();
                                    _fetchWeatherData();
                                  },
                                );
                              },
                            ),
                          ),

                        const SizedBox(height: 10),

                        // Current City Display

                        const SizedBox(height: 10),

                        // Main Weather Card
                        SizedBox(
                          width: double.infinity,
                          child: Card(
                            color: Colors.black45,
                            elevation: 10,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Column(
                                  children: [
                                    Text(
                                      toCelsius(
                                        weatherData!['list'][0]['main']['temp']
                                            .toDouble(),
                                      ),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 40,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    Icon(
                                      weatherData!['list'][0]['weather'][0]['main'] ==
                                                  'Clouds' ||
                                              weatherData!['list'][0]['weather'][0]['main'] ==
                                                  'Rain'
                                          ? Icons.cloud
                                          : Icons.sunny,
                                      size: 60,
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      weatherData!['list'][0]['weather'][0]['main'],
                                      style: const TextStyle(fontSize: 20),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Hourly Forecast Section
                        const Text(
                          'Hourly Forecast',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 14),

                        SizedBox(
                          height: 150,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: 5,
                            itemBuilder: (BuildContext context, int index) {
                              final hourlyForecast =
                                  weatherData!['list'][index + 1];
                              final time = DateTime.parse(
                                hourlyForecast['dt_txt'],
                              );
                              final hourlyTemp = hourlyForecast['main']['temp'];
                              final hourlySky =
                                  hourlyForecast['weather'][0]['main'];

                              return HourlyForecastCards(
                                time: DateFormat.j().format(time),
                                temp: toCelsius(
                                  hourlyTemp.toDouble(),
                                ), // Display in Celsius
                                icon:
                                    hourlySky == 'Clouds' || hourlySky == 'Rain'
                                        ? Icons.cloud
                                        : Icons.sunny,
                              );
                            },
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Additional Info Section
                        const Text(
                          'Additional information',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 14),
                        Card(
                          color: Colors.black45,
                          child: Padding(
                            padding: const EdgeInsets.all(13.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                AdditionalCards(
                                  icon: WeatherIcons.humidity,
                                  label: 'Humidity',
                                  value:
                                      '${weatherData!['list'][0]['main']['humidity']} %',
                                ),
                                AdditionalCards(
                                  icon: Icons.wind_power,
                                  label: 'Wind Speed',
                                  value:
                                      '${weatherData!['list'][0]['wind']['speed']} m/s',
                                ),
                                AdditionalCards(
                                  icon: WeatherIcons.barometer,
                                  label: 'Pressure',
                                  value:
                                      '${weatherData!['list'][0]['main']['pressure']} hPa',
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 30),
                        Center(
                          child: Text(
                            year.toString() +
                                '-' +
                                month.toString() +
                                '-' +
                                day.toString(),
                            style: TextStyle(fontSize: 20),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
    );
  }
}
