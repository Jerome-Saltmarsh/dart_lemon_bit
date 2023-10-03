
import 'dart:convert';

import 'package:gamestream_users/database/firestore/extensions/document_extensions.dart';
import 'package:googleapis/firestore/v1.dart';
import 'package:typedef/json.dart';


List<Json> getCharactersJsonFromUserDocument(Document document) =>
    (document.getFieldArrayValues('characters') ?? [])
      .map((field) => field.stringValue)
      .map((e) => e != null ? jsonDecode(e) : '')
      .toList().cast<Json>();



