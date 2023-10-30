import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  List<dynamic> _searchResults = [];
  bool _searching = false;

  Future<void> _fetchMovies(String query) async {
    final String apiKey =
        '01daaca0a538d06860c29b97e1a80188'; // Replace with your TMDb API key
    final String url =
        'https://api.themoviedb.org/3/search/movie?api_key=$apiKey&query=$query';

    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final results = data['results'];
      setState(() {
        _searchResults = results;
      });
    } else {
      throw Exception('Failed to load movies');
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          decoration: const InputDecoration(
            hintText: 'Search for movies...',
          ),
          onChanged: (query) {
            setState(() {
              _searching = query.isNotEmpty;
            });
            _fetchMovies(query);
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              final query = _searchController.text;
              _fetchMovies(query);
            },
          ),
        ],
      ),
      body: _searching
          ? ListView.builder(
              itemCount: _searchResults.length,
              itemBuilder: (context, index) {
                final movie = _searchResults[index];
                final title = movie['title'];
                final imageUrl =
                    'https://image.tmdb.org/t/p/w200${movie['poster_path']}';

                return ListTile(
                  leading: Image.network(imageUrl),
                  title: Text(title),
                  onTap: () {
                    // Handle tapping on a movie
                  },
                );
              },
            )
          : const Center(
              child: Text('Start typing to search for movies...'),
            ),
    );
  }
}
