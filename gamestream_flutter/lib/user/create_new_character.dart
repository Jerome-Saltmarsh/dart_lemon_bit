import 'package:http/http.dart' as http;

Future createNewCharacter({
  required String userId,
  required String characterName,
  required String scheme,
  required String host,
  required int port,
}) async =>
    await http.post(Uri.parse('$scheme://$host:$port/new'));