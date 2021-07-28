import 'dart:convert';
import 'package:archive/archive.dart';

GZipEncoder gZipEncoder = GZipEncoder();
GZipDecoder gZipDecoder = GZipDecoder();

String encode(dynamic data) {
  List<int> i = gZipEncoder.encode(utf8.encode(jsonEncode(data).replaceAll(" ", "")));
  if (i != null) {
    return base64.encode(i);
  }
  return "";
}

dynamic decode(String data) {
  return jsonDecode(
      (utf8.decode(gZipDecoder.decodeBytes(base64.decode(data).toList()))));
}

/// [state, direction, positionX, positionY]
List<dynamic> unparseNpcs(List<dynamic> parsedCharacters){
  return parsedCharacters.map(unparseNpc).toList();
}

List<dynamic> unparsePlayers(List<dynamic> parsedCharacters){
  return parsedCharacters.map(unparsePlayer).toList();
}

dynamic unparseNpc(dynamic parsedCharacter){
  List<String> attributes = parsedCharacter.split(" ");
  return [
    int.parse(attributes[0]),
    int.parse(attributes[1]),
    double.parse(attributes[2]),
    double.parse(attributes[3]),
  ];
}

dynamic unparsePlayer(dynamic parsedCharacter){
  List<String> attributes = parsedCharacter.split(" ");
  return [
    int.parse(attributes[0]),
    int.parse(attributes[1]),
    double.parse(attributes[2]),
    double.parse(attributes[3]),
    int.parse(attributes[4]),
  ];
}
