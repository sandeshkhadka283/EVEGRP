import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:evegrp/bloc_event.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MoviesEvent {}

class MoviesState extends Equatable {
  @override
  List<Object?> get props => [];
}

class MoviesLoadingState extends MoviesState {}

class MoviesLoadedState extends MoviesState {
  final List<dynamic> movies;

  MoviesLoadedState(this.movies);

  @override
  List<Object?> get props => [movies];
}

class MoviesErrorState extends MoviesState {
  final String error;

  MoviesErrorState(this.error);

  @override
  List<Object?> get props => [error];
}

class MoviesBloc extends Bloc<MoviesEvent, MoviesState> {
  MoviesBloc() : super(MoviesLoadingState());

  @override
  MoviesState get initialState => MoviesLoadingState();

  @override
  Stream<MoviesState> mapEventToState(MoviesEvent event) async* {
    if (event is FetchMovies) {
      yield MoviesLoadingState();
      try {
        final movies = await fetchMovies();
        yield MoviesLoadedState(movies);
      } catch (e) {
        yield MoviesErrorState('Failed to fetch movies: $e');
      }
    }
  }

  Future<List<dynamic>> fetchMovies() async {
    final String apiKey =
        '01daaca0a538d06860c29b97e1a80188'; // Replace with your TMDb API key
    final String url =
        'https://api.themoviedb.org/3/movie/popular?api_key=$apiKey';

    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['results'];
    } else {
      throw Exception('Failed to load movies');
    }
  }
}
