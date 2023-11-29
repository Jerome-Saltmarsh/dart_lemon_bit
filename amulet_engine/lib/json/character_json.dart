import '../packages/isometric_engine/packages/type_def/json.dart';

typedef CharacterJson = Map<String, dynamic>;

extension CharacterJsonExtension on CharacterJson {

  String get uuid => getString('uuid');

  String get name => getString('name');
}
