import 'dart:convert';
import 'package:http/http.dart' as http;

const _baseUrl = 'https://api.themoviedb.org/3';
const _headers = {
  'accept': 'application/json',
  'Authorization':
      'Bearer eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiI5MjljOTc2YjU4NGU1N2JmZjEzYzA2YWU1NDdkNWMyZiIsIm5iZiI6MTc1NzE1NTY4My40Nywic3ViIjoiNjhiYzExNjM2NGQyNzg3ODliMWY0OGRmIiwic2NvcGVzIjpbImFwaV9yZWFkIl0sInZlcnNpb24iOjF9.LfgQXnZB_-tmj384HcKmr_9dheD3JqSRNFhE27Il9rc',
};

List<Map<String, dynamic>> _mapMovies(dynamic body) {
  final List results = body['results'] ?? [];
  return results.map<Map<String, dynamic>>((movie) {
    return {
      'movie_name': movie['title'] ?? '',
      'poster_url': movie['poster_path'] != null
          ? 'https://image.tmdb.org/t/p/w500${movie['poster_path']}'
          : null,
      'tmdb_code': movie['id'].toString(),
      'year': (movie['release_date'] ?? '').toString().split('-').first,
    };
  }).toList();
}

/// Trending (day)
Future<List<Map<String, dynamic>>> fetchTrendingMovies() async {
  final url = '$_baseUrl/trending/movie/day?language=en-US';
  final res = await http.get(Uri.parse(url), headers: _headers);
  if (res.statusCode != 200) return [];
  return _mapMovies(jsonDecode(res.body));
}

/// Popular (good for “current hits”)
Future<List<Map<String, dynamic>>> fetchPopularMovies() async {
  final url = '$_baseUrl/movie/popular?language=en-US&page=1';
  final res = await http.get(Uri.parse(url), headers: _headers);
  if (res.statusCode != 200) return [];
  return _mapMovies(jsonDecode(res.body));
}

/// Top rated (lots of older / classic titles)
Future<List<Map<String, dynamic>>> fetchTopRatedMovies() async {
  final url = '$_baseUrl/movie/top_rated?language=en-US&page=1';
  final res = await http.get(Uri.parse(url), headers: _headers);
  if (res.statusCode != 200) return [];
  return _mapMovies(jsonDecode(res.body));
}
