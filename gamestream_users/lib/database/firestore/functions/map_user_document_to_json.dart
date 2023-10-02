
import 'package:gamestream_users/database/firestore/extensions/document_extensions.dart';
import 'package:googleapis/firestore/v1.dart';
import 'package:typedef/json.dart';


Json mapUserDocumentToJson(Document document) {

  final characters = (document.getFieldArrayValues('characters') ?? []);

  return {
    'username' : document.getFieldString('username'),
    'characters': characters
        .map((field) => field.stringValue)
        .toList(growable: false)
  };
}


