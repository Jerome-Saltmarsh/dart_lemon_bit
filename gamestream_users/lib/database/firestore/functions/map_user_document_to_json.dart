
import 'dart:convert';

import 'package:gamestream_users/database/firestore/extensions/document_extensions.dart';
import 'package:googleapis/firestore/v1.dart';
import 'package:typedef/json.dart';


Json mapUserDocumentToJson(Document document) => {
    'username' : document.getFieldString('username'),
    'characters': (document.getFieldArrayValues('characters') ?? [])
        .map((field) => field.stringValue)
        .map((e) => e != null ? jsonDecode(e) : '')
        .toList(growable: false)
  };


