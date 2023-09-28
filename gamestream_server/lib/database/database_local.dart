import 'dart:convert';
import 'dart:io';

import 'package:gamestream_server/database/functions/map_isometric_player_to_json.dart';
import 'package:gamestream_server/isometric/isometric_player.dart';
import 'package:gamestream_server/packages.dart';
import 'package:gamestream_server/packages/lemon_io/src/write_json_to_file.dart';
import 'package:typedef/json.dart';

import 'database.dart';

class DatabaseLocal implements Database {

  var value = 50;

  final dbDirectory = Directory('${Directory.current.path}/database');
  final dbPath = '${Directory.current.path}/database';

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
      directory: dbPath,
      contents: json,
    );
  }

  @override
  Future<List<Json>> getUserCharacters(String userId) async {
    final exists = await dbDirectory.exists();
    var characters = <Json>[];

    if (!exists){
      return [];
    }

    final children = dbDirectory.listSync();
    for (final entity in children){
      if (entity is! File) {
        continue;
      }
      final fileEncoded = await entity.readAsString();
      final fileJson = jsonDecode(fileEncoded) as Map<String, dynamic>;
      characters.add(fileJson);
    }
    return characters;
  }

  @override
  Future<Json> getCharacter(String characterId) async {
    final exists = await dbDirectory.exists();

    if (!exists){
      throw Exception('dbDirectory does not exist');
    }

    final children = dbDirectory.listSync();
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
}