import 'dart:io';

import 'package:gamestream_server/database/functions/map_isometric_player_to_json.dart';
import 'package:gamestream_server/isometric/isometric_player.dart';
import 'package:gamestream_server/packages/lemon_io/src/write_json_to_file.dart';

import 'database.dart';

class DatabaseLocal implements Database {

  var value = 50;

  final currentPath = Directory.current.path;

  String get dbDir => '$currentPath/database';

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
      directory: dbDir,
      contents: json,
    );
  }

  @override
  Future<List<String>> getUserCharacters(String userId) async {
    final dbDir = this.dbDir;
    final dbDirFile = Directory(dbDir);
    final exists = await dbDirFile.exists();

    var names = <String>[];

    if (!exists){
      return names;
    }

    final children = dbDirFile.listSync();
    for (final child in children){
      names.add(child.uri.pathSegments.last.split('.').first);
    }
    return names;
  }
}