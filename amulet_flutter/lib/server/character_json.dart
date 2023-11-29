import 'package:typedef/json.dart';

typedef CharacterJson = Map<String, dynamic>;

extension CharacterJsonExtension on CharacterJson {

  String get uuid => getString('uuid');

  String get name => getString('name');
}
