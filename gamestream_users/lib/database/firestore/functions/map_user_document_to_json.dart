
import 'package:googleapis/firestore/v1.dart';
import 'package:typedef/json.dart';

Json mapUserDocumentToJson(Document document){

  final fields = document.fields;
  if (fields == null) {
    throw Exception('fields == null');
  }

  final characters = fields['characters'];
  if (characters == null) {
    throw Exception('fields[characters] == null');
  }

  final arrayValue = characters.arrayValue;
  if (arrayValue == null) {
    throw Exception('fields[characters].arrayValue == null');
  }

  final values = arrayValue.values ?? [];
  return {
    'characters': values
        .map((character) => character.stringValue)
        .toList(growable: false)
  };
}