import 'dart:convert';
import 'dart:io';

import 'package:typedef/json.dart';
import 'package:uuid/v4.dart';

import 'database.dart';

class DatabaseLocal implements Database {

  final String path;
  var value = 50;

  late final Directory dirDatabase;
  late final Directory dirCharacters;
  late final Directory dirUsers;
  final uuid = UuidV4();

  DatabaseLocal({required this.path}){
    print('DatabaseLocal(path: "$path")');

    final pathDatabase = '$path/database';
    dirDatabase = Directory(pathDatabase);
    dirCharacters = Directory('$pathDatabase/characters');
    dirUsers = Directory('$pathDatabase/users');

    dirDatabase.createSync();
    dirCharacters.createSync();
    dirUsers.createSync();
  }

  @override
  Future connect() => Future.delayed(const Duration(milliseconds: 100));

  // @override
  // void persist(IsometricPlayer player) {
  //
  //   final json = mapIsometricPlayerToJson(player);
  //   final uuid = json['uuid'];
  //   if (uuid == null){
  //     throw Exception('uuid is null');
  //   }
  //   writeJsonToFile(
  //     fileName: '$uuid.json',
  //     directory: dirCharacters.path,
  //     contents: json,
  //   );
  // }

  @override
  Future<List<Json>> getUser(String userId) async {

    final user = await findUser(userId);
    final userCharacterIds = user.getList<String>('characters');
    final userCharacters = <Json>[];

    for (final userCharacterId in userCharacterIds){
       final userCharacter = await getCharacter(userCharacterId);
       userCharacters.add(userCharacter);
    }

    return userCharacters;
  }

  @override
  Future<Json> getCharacter(String characterId) async {
    final exists = await dirCharacters.exists();

    if (!exists){
      throw Exception('dbDirectory does not exist');
    }

    final children = dirCharacters.listSync();
    for (final entity in children){
      if (!entity.uri.pathSegments.last.contains(characterId)){
        continue;
      }
      if (entity is! File) {
        continue;
      }
      final fileEncoded = await entity.readAsString();
      final fileJson = jsonDecode(fileEncoded) as Map<String, dynamic>;
      return fileJson;
    }
    throw Exception('getCharacter($characterId) - could not be found');
  }

  Future<Json> findUser(String userId) async {
    final userFiles = dirUsers.listSync();
    for (final entity in userFiles){
      if (entity is! File) {
        continue;
      }
      if (!entity.path.contains(userId)){
        continue;
      }
      final fileEncoded = await entity.readAsString();
      return jsonDecode(fileEncoded) as Json;
    }
    throw Exception('user could not be found $userId');
  }

  @override
  Future<String> createCharacter({
    required String userId,
    required String name,
    required int complexion,
    required int hairType,
    required int hairColor,
    required int gender,
    required int headType,
  }) async {

    final user = await findUser(userId);
    final userCharacters = user.getList<String>('characters');
    final characterId = uuid.generate();
    userCharacters.add(characterId);

    final userFile = File('${dirUsers.path}/$userId.json');
    userFile.writeAsString(jsonEncode({
      'characters': userCharacters
    }));

    final characterFile = File('${dirCharacters.path}/$characterId.json');

    characterFile.writeAsString(
      jsonEncode({
        "uuid": characterId,
        "name": name,
        "equipped_helm": 0,
        "equipped_body": 0,
        "equipped_legs": 1,
        "equipped_shoes": 1,
        "equipped_hand_left": 0,
        "equipped_hand_right": 1,
        "weapons": [
          "Old_Bow",
          "Rusty_Old_Sword",
          "-",
          "-"
        ],
        "items": [
          "Blink_Dagger",
          "-",
          "Staff_Of_Flames",
          "Basic_Leather_Armour",
          "-",
          "-"
        ],
        "complexion": complexion,
        "equipped_weapon_index": 0,
        "gender": gender,
        "hair_type": hairType,
        "hair_color": hairColor,
        "experience": 0,
        "level": 1,
      })
    );
    characterFile.createSync();
    return characterId;
  }

  @override
  Future saveCharacter(Json characterJson) {
    final characterUuid = characterJson.getString('uuid');
    final characterFile = File('${dirCharacters.path}/$characterUuid.json');
    if (!characterFile.existsSync()){
      characterFile.createSync();
    }
    return characterFile.writeAsString(jsonEncode(characterJson));
  }

}