import 'package:evegrp/MovieDetailsPage.dart';
import 'package:evegrp/SearchPage.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shimmer/shimmer.dart';
import 'dart:convert';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:connectivity/connectivity.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const HomePage(),
      theme: ThemeData.dark(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _internetErrorShown = false; // Add this variable

  Future<List<dynamic>> fetchMovies(String endpoint) async {
    final connectivityResult = await (Connectivity().checkConnectivity());

    if (connectivityResult == ConnectivityResult.none) {
      // Display a SnackBar for no internet connection.
      if (!_internetErrorShown) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.transparent,
            elevation: 8, // Elevation for the custom SnackBar
            content: Container(
              decoration: BoxDecoration(
                color: Colors.red, // Background color
                borderRadius:
                    BorderRadius.circular(8), // Customize the border radius
              ),
              padding: const EdgeInsets.all(16), // Padding for the content
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'No internet connection. Please check your network.',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      _refresh();
                    },
                    child: Text(
                      'RETRY',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
        _internetErrorShown = true; // Mark the error as shown
      }

      return Future.error('No internet connection. Please check your network.');
    }
    const String apiKey =
        '01daaca0a538d06860c29b97e1a80188'; // Replace with your TMDb API key
    final String url =
        'https://api.themoviedb.org/3/movie/$endpoint?api_key=$apiKey';

    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['results'];
    } else {
      throw Exception('Failed to load $endpoint movies');
    }
  }

  Future<void> _refresh() async {
    // You can trigger a refresh by calling this function.
    setState(() {
      // Set the state to loading or show a loading indicator.
    });

    try {
      await fetchMovies("popular"); // Replace with your data loading function.
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          duration: Duration(seconds: 1),
          backgroundColor: Colors.transparent,
          elevation: 8, // Elevation for the custom SnackBar
          content: Container(
            decoration: BoxDecoration(
              color: Colors.green, // Background color
              borderRadius:
                  BorderRadius.circular(8), // Customize the border radius
            ),
            padding: const EdgeInsets.all(16), // Padding for the content
            child: const Text(
              'Refreshed successfully',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white, // Text color
              ),
            ),
          ),
        ),
      );

      // Update the state with the new data.
    } catch (e) {
      // Handle errors if any.
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: RefreshIndicator(
          onRefresh: _refresh,
          child: SingleChildScrollView(
            child: Column(
              children: [
                IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () {
                    // Navigate to the search page when the search icon is pressed.
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => SearchPage()));
                  },
                ),
                FutureBuilder(
                  future: fetchMovies("popular"),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Shimmer.fromColors(
                        baseColor: Colors.grey.shade300,
                        highlightColor: Colors.grey.shade100,
                        child: _buildLoadingUI(),
                      );
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    } else {
                      final List<dynamic> movies =
                          snapshot.data as List<dynamic>;
                      final moviePosters = movies.map((movie) {
                        return 'https://image.tmdb.org/t/p/w200${movie['poster_path']}';
                      }).toList();

                      return Column(
                        children: [
                          Stack(
                            children: [
                              CarouselSlider(
                                items: moviePosters.map((posterUrl) {
                                  return GestureDetector(
                                    onTap: () {},
                                    child: SizedBox(
                                      width: double.infinity,
                                      child: Image.network(
                                        posterUrl,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  );
                                }).toList(),
                                options: CarouselOptions(
                                  height: 250.0,
                                  enlargeCenterPage: true,
                                  autoPlay: true,
                                  aspectRatio: 16 / 9,
                                ),
                              ),
                            ],
                          ),
                        ],
                      );
                    }
                  },
                ),
                _buildMovieSection('Upcoming Movies', 'upcoming'),
                _buildMovieSection('Top Rated Movies', 'top_rated'),
                _buildMovieSection('Now Playing Movies', 'popular'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMovieSection(String sectionTitle, String endpoint) {
    return FutureBuilder(
      future: fetchMovies(endpoint),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Shimmer.fromColors(
            baseColor: Colors.grey.shade100,
            highlightColor: Colors.grey.shade100,
            child: _buildLoadingUI(),
          );
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else {
          final List<dynamic> movies = snapshot.data as List<dynamic>;
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    const Icon(Icons.movie, size: 24, color: Colors.blue),
                    const SizedBox(width: 8),
                    Text(
                      sectionTitle,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 250,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: movies.length,
                  itemBuilder: (context, index) {
                    final movie = movies[index];
                    final title = movie['title'];
                    final imageUrl =
                        'https://image.tmdb.org/t/p/w200${movie['poster_path']}';

                    return GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(_createRoute(movie));
                      },
                      child: Container(
                        width: 150,
                        margin: const EdgeInsets.all(10),
                        child: Column(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8.0),
                              child: Image.network(
                                imageUrl,
                                width: 150,
                                height: 200,
                                fit: BoxFit.cover,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              title,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        }
      },
    );
  }

  Route _createRoute(Map<String, dynamic> movie) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) {
        return MovieDetailsPage(movie: movie);
      },
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = 0.0;
        const end = 1.0;
        const curve = Curves.easeInOut;
        var tween =
            Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
        var opacityAnimation = animation.drive(tween);

        return FadeTransition(
          opacity: opacityAnimation,
          child: child,
        );
      },
    );
  }

  Widget _buildLoadingUI() {
    return Column(
      children: [
        Stack(
          children: [
            CarouselSlider(
              items: [1, 2, 3, 4, 5].map((item) {
                return Container(
                  width: double.infinity,
                  color: Colors.grey[300],
                );
              }).toList(),
              options: CarouselOptions(
                height: 250.0,
                enlargeCenterPage: true,
                autoPlay: true,
                aspectRatio: 16 / 9,
              ),
            ),
            Positioned(
              top: 200.0,
              left: 20.0,
              child: Container(
                width: 200.0,
                height: 30.0,
                color: Colors.grey[300],
              ),
            ),
          ],
        ),
        const SizedBox(height: 10.0),
        SizedBox(
          height: 250.0,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: 5,
            itemBuilder: (context, index) {
              return Container(
                width: 150.0,
                margin: const EdgeInsets.all(10.0),
                child: Column(
                  children: [
                    Container(
                      width: 150.0,
                      height: 200.0,
                      color: Colors.grey[300],
                    ),
                    const SizedBox(height: 5.0),
                    Container(
                      width: 100.0,
                      height: 20.0,
                      color: Colors.grey[300],
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
