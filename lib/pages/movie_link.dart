import 'package:http/http.dart' as http;

Future<String> movie_ink(code) async{
  final url = Uri.parse('http://76.164.199.176:5000/get_m3u8?movie_code=$code');
  
  final response = await http.get(url);
  final result_data = response.body;
  print(result_data);
return result_data;
}