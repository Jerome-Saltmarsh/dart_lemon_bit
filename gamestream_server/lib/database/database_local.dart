import 'dart:io';

import 'package:gamestream_server/database/functions/map_isometric_player_to_json.dart';
import 'package:gamestream_server/isometric/isometric_player.dart';
import 'package:gamestream_server/packages/lemon_io/src/write_json_to_file.dart';

import 'database.dart';

class DatabaseLocal implements Database {

  var value = 50;

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
      directory: '${Directory.current.path}/database',
      contents: json,
    );
  }
}