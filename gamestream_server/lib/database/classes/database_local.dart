import 'dart:convert';
import 'dart:io';

import 'package:gamestream_server/database/functions/map_isometric_player_to_json.dart';
import 'package:gamestream_server/isometric/isometric_player.dart';
import 'package:gamestream_server/packages.dart';
import 'package:gamestream_server/packages/lemon_io/src/write_json_to_file.dart';
import 'package:typedef/json.dart';

import 'database.dart';

class DatabaseLocal implements Database {

  final String path;
  var value = 50;

  late final Directory dirCharacters;
  late final Directory dirUsers;

  DatabaseLocal({required this.path}){
    dirCharacters = Directory('$path/database/characters');
    dirUsers = Directory('$path/database/users');

    if (!dirCharacters.existsSync()){
      dirCharacters.createSync();
    }

    if (!dirUsers.existsSync()){
      dirUsers.createSync();
    }
  }

  @override
  Future connect() => Future.delayed(const Duration(milliseconds: 100));

  @override
  Future<int> getHighScore() => Future.value(value);

  @override
  Future writeHighScore(int value) async {
    this.value = value;
  }

  @override
  void persist(IsometricPlayer player) {

    final json = mapIsometricPlayerToJson(player);
    final uuid = json['uuid'];
    if (uuid == null){
      throw Exception('uuid is null');
    }
    writeJsonToFile(
      fileName: '$uuid.json',
      directory: dirCharacters.path,
      contents: json,
    );
  }

  @override
  Future<List<Json>> getUserCharacters(String userId) async {

    final user = await findUser(userId);
    final userCharacterIds = (user['characters'] as List).cast<String>();
    final userCharacters = <Json>[];

    for (final userCharacterId in userCharacterIds){
       final userCharacter = await getCharacter(userCharacterId);
       userCharacters.add(userCharacter);
    }

    return userCharacters;
    // final characters = <Json>[];
    // final characterFiles = dirCharacters.listSync();
    //
    // for (final entity in characterFiles){
    //   if (entity is! File) {
    //     continue;
    //   }
    //   final fileEncoded = await entity.readAsString();
    //   final character = jsonDecode(fileEncoded) as Json;
    //   characters.add(character);
    // }
    // return characters;
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
  Future createCharacter({
    required String name,
    required int complexion,
    required int hairType,
    required int hairColor,
    required int gender,
    required int headType,
  }) async {
    // TODO: implement createCharacter
    throw UnimplementedError();
  }

}