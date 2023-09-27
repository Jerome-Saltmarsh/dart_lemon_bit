import 'package:http/http.dart' as http;

Future<String> getCharacter() async {

  final url = Uri.parse('http://localhost:8082'); // Replace with your desired URL

  // Send an HTTP GET request
  final response = await http.get(url).catchError((error){
    print(error);
  });

  if (response.statusCode == 200) {
    // If the server returns a 200 OK response, parse the JSON
    final jsonResponse = response.body;
    print('Response: $jsonResponse');
  } else {
    // If the server did not return a 200 OK response, throw an exception
    throw Exception('Failed to load data');
  }

  return response.body;
}