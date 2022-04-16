
import 'package:bleed_common/CharacterType.dart';
import 'package:bleed_common/ItemType.dart';
import 'package:bleed_common/Tile.dart';
import 'package:bleed_common/ObjectType.dart';
import 'package:flutter/cupertino.dart';
import 'package:gamestream_flutter/classes/Character.dart';
import 'package:gamestream_flutter/classes/EnvironmentObject.dart';
import 'package:gamestream_flutter/classes/Item.dart';
import 'package:lemon_math/Vector2.dart';
import 'package:lemon_watch/watch.dart';

import 'enums.dart';


class EditorState {
  final List<EnvironmentObject> environmentObjects = [];
  final Watch<bool> waitForPlayersToJoin = Watch(true);
  final Watch<int> numberOfPlayers = Watch(8);
  final Watch<TeamType> teamType = Watch(TeamType.Solo);
  final Watch<int> teamSize = Watch(1);
  final Watch<int> numberOfTeams= Watch(4);
  int selectedCollectable = -1;
  final List<Vector2> teamSpawnPoints = [];
  final Watch<TimeSpeed> timeSpeed = Watch(TimeSpeed.Normal);
  final Watch<Vector2?> selected = Watch(null);
  final Watch<ToolTab> tab = Watch(ToolTab.Tiles);
  final Watch<int> tile = Watch(Tile.Grass);
  final Watch<CharacterType> characterType = Watch(CharacterType.Human);
  final itemType = Watch(ItemType.Shotgun);
  final Watch<ObjectType> objectType = Watch(objectTypes.first);
  final Watch<EditorDialog> dialog = Watch(EditorDialog.None);
  final mapNameController = TextEditingController();
  final Watch<String> error = Watch("");
  List<Character> characters = [];
  final List<Item> items = [];
}

