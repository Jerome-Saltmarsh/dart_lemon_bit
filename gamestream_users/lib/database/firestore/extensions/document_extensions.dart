
import 'package:googleapis/firestore/v1.dart';

extension DocumentExtensions on Document {

  String? getFieldString(String fieldName) =>
      getField(fieldName)?.stringValue;

  List<Value>? getFieldArrayValues(String fieldName) =>
      getFieldArray(fieldName)?.values;

  ArrayValue? getFieldArray(String fieldName) =>
      getField(fieldName)?.arrayValue;

  Value? getField(String fieldName) =>
      this.fields?[fieldName];
}