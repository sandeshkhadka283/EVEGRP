import 'package:evegrp/movies_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: BlocProvider(
        create: (context) => MoviesBloc(),
        child: HomePage(),
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('TMDb Movies'),
      ),
      body: BlocBuilder<MoviesBloc, MoviesState>(
        builder: (context, state) {
          if (state is MoviesLoadingState) {
            return Center(child: CircularProgressIndicator());
          } else if (state is MoviesLoadedState) {
            final movies = state.movies;
            return ListView.builder(
              itemCount: movies.length,
              itemBuilder: (context, index) {
                final movie = movies[index];
                return ListTile(
                  title: Text(movie['title']),
                );
              },
            );
          } else if (state is MoviesErrorState) {
            return Center(child: Text(state.error));
          }
          return Container(); // Handle other states if necessary
        },
      ),
    );
  }
}
