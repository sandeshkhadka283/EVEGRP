import 'package:evegrp/MovieDetailsPage.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shimmer/shimmer.dart';
import 'dart:convert';
import 'package:carousel_slider/carousel_slider.dart';

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

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  Future<List<dynamic>> fetchMovies(String endpoint) async {
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

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: SingleChildScrollView(
          child: Column(
            children: [
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
                    final List<dynamic> movies = snapshot.data as List<dynamic>;
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
                    Icon(Icons.movie, size: 24, color: Colors.blue),
                    SizedBox(width: 8),
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
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                MovieDetailsPage(movie: movie),
                          ),
                        );
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
