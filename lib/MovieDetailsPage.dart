import 'package:flutter/material.dart';

class MovieDetailsPage extends StatelessWidget {
  final Map<String, dynamic> movie;

  const MovieDetailsPage({super.key, required this.movie});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(movie['title'] ?? 'Movie Details'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  height: 300,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage(
                        'https://image.tmdb.org/t/p/w400${movie['poster_path'] ?? ''}',
                      ),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Center(
                      child: Text(
                        movie['title'] ?? 'Movie Title',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildSectionTitle('Overview', Icons.description, Colors.blue),
            _buildSectionContent(movie['overview'] ?? 'No overview available'),
            _buildSectionTitle(
                'Release Date', Icons.calendar_today, Colors.green),
            _buildSectionContent(
                movie['release_date'] ?? 'No release date available'),
            _buildSectionTitle('Original Title', Icons.title, Colors.orange),
            _buildSectionContent(
                movie['originalTitle'] ?? 'No original title available'),
            _buildSectionTitle(
                'Original Language', Icons.language, Colors.purple),
            _buildSectionContent(
                movie['originalLanguage'] ?? 'No original language available'),
            _buildSectionTitle('Popularity', Icons.star, Colors.yellow),
            _buildSectionContent(
                movie['popularity']?.toStringAsFixed(2) ?? 'N/A'),
            _buildSectionTitle('Vote Average', Icons.star, Colors.yellow),
            _buildSectionContent(
                movie['voteAverage']?.toStringAsFixed(2) ?? 'N/A'),
            _buildSectionTitle('Vote Count', Icons.people, Colors.blue),
            _buildSectionContent(movie['voteCount']?.toString() ?? 'N/A'),
            _buildSectionTitle('Genres', Icons.category, Colors.red),
            _buildGenres(movie['genre_ids']),
            // Add more movie details as needed
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16.0, 20.0, 16.0, 8.0),
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionContent(String content) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Text(
        content,
        style: const TextStyle(
          fontSize: 16,
        ),
      ),
    );
  }

  Widget _buildGenres(List<dynamic> genreIds) {
    if (genreIds.isEmpty) {
      return _buildSectionContent('No genre information available');
    }

    final genreNames = getGenreNames(genreIds.cast<int>());
    final genreText = genreNames.join(', ');

    return _buildSectionContent(genreText);
  }

  List<String> getGenreNames(List<int> genreIds) {
    // Replace with your genre mapping based on the API or use a predefined genre list
    final genreMap = {
      28: 'Action',
      12: 'Adventure',
      16: 'Animation',
      35: 'Comedy',
      80: 'Crime',
      99: 'Documentary',
      18: 'Drama',
      10751: 'Family',
      14: 'Fantasy',
      36: 'History',
      27: 'Horror',
      10402: 'Music',
      9648: 'Mystery',
      10749: 'Romance',
      878: 'Science Fiction',
      10770: 'TV Movie',
      53: 'Thriller',
      10752: 'War',
      37: 'Western',
    };

    final genreNames = genreIds.map((id) {
      final name = genreMap[id];
      return name ?? 'Unknown Genre';
    }).toList();

    return genreNames;
  }
}
