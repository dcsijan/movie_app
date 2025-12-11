import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';

String keyword = '';



Future<dynamic> TMDB (keyword) async{


  final url = Uri.parse("https://api.themoviedb.org/3/search/movie?query="+keyword+"&include_adult=false&language=en-US&page=1");

  final response = await http.get(url,headers : {
    "accept": "application/json",
    "Authorization": "Bearer eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiI5MjljOTc2YjU4NGU1N2JmZjEzYzA2YWU1NDdkNWMyZiIsIm5iZiI6MTc1NzE1NTY4My40Nywic3ViIjoiNjhiYzExNjM2NGQyNzg3ODliMWY0OGRmIiwic2NvcGVzIjpbImFwaV9yZWFkIl0sInZlcnNpb24iOjF9.LfgQXnZB_-tmj384HcKmr_9dheD3JqSRNFhE27Il9rc"
});
final Map<String, dynamic> responseData = jsonDecode(response.body);

// Now extract the list from the map
final List<dynamic> data = responseData['results'];

List<Map<String, dynamic>> movies = [];

  //print(response.body);

  for (var id in data){
   
    movies.add({
      'tmdb_code': id['id'],  
      'movie_name': id['original_title'],
      'poster_url': id['poster_path'] != null
    ? 'https://image.tmdb.org/t/p/w500${id['poster_path']}'
    : null,

    });
    
    

  }
  return movies;
  

  // return 'Movie Not Found';
}

// void onSearchChanged(String text) async{
//   print('User typed: $text');
  
//   keyword = text;

//   final moviesdata = await TMDB(keyword);
  

  
  
// }
