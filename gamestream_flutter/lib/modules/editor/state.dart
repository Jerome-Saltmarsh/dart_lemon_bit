
import 'package:bleed_common/library.dart';
import 'package:flutter/cupertino.dart';
import 'package:gamestream_flutter/classes/EnvironmentObject.dart';
import 'package:gamestream_flutter/classes/Item.dart';
import 'package:gamestream_flutter/modules/isometric/classes.dart';
import 'package:lemon_math/Vector2.dart';
import 'package:lemon_watch/watch.dart';

import 'enums.dart';

class EditorState {
  final environmentObjects = <EnvironmentObject>[];
  final waitForPlayersToJoin = Watch(true);
  final numberOfPlayers = Watch(8);
  final teamType = Watch(TeamType.Solo);
  final teamSize = Watch(1);
  final numberOfTeams= Watch(4);
  final teamSpawnPoints = <Vector2>[];
  final timeSpeed = Watch(TimeSpeed.Normal);
  final selected = Watch<Vector2?>(null);
  final tab = Watch(ToolTab.Tiles);
  final tile = Watch(Tile.Grass);
  final characterType = Watch(CharacterType.Human);
  final itemType = Watch(ItemType.Shotgun);
  final objectType = Watch(objectTypes.first);
  final dialog = Watch(EditorDialog.None);
  final mapNameController = TextEditingController();
  final error = Watch("");
  final items = <Item>[];
  var characters = <Character>[];
  var selectedCollectable = -1;
}

