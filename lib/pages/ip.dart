import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart' show rootBundle;


Future<Map<String,String>> server () async {

final url =  Uri.parse('http://ip-api.com/json');

final response = await http.get(url);

  final result = jsonDecode(response.body);
  final country_code = result['countryCode'].toString();
  final ip_data = result['query'];

  //api


  // final String jsonString = await rootBundle.loadString('assets/countries.json');
  // final filePath = r'C:\Users\Sijan DC\Desktop\First_flutter_project\app\assets\countries.json';
 
  // final file = File(filePath);
  final contents = await rootBundle.loadString('assets/countries.json');
  // final contents = await file.readAsString();

   
  final List<dynamic> data = jsonDecode(contents);
    
    
    for (var country in data) {
      
      if (country['code'].toString() == country_code) {
       print('Flag: ${country['flag']}');
        return {
          'ip' :ip_data,
          'flag':country['flag']
        };
      }
    }

    print('country code "$country_code" not found.');

  
  return {
    'ip': ip_data,
    'flag': '🏳️',
  };
  

}

void main () async{

  final result = await server();
  print(result);
}