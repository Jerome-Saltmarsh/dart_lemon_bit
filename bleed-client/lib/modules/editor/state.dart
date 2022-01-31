
import 'package:bleed_client/classes/Character.dart';
import 'package:bleed_client/common/CharacterType.dart';
import 'package:bleed_client/common/ItemType.dart';
import 'package:bleed_client/common/Tile.dart';
import 'package:bleed_client/common/enums/ObjectType.dart';
import 'package:flutter/cupertino.dart';
import 'package:lemon_math/Vector2.dart';
import 'package:lemon_watch/watch.dart';

import 'enums.dart';


class EditorState {
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
  final Watch<Tile> tile = Watch(Tile.Grass);
  final Watch<CharacterType> characterType = Watch(CharacterType.Human);
  final Watch<ItemType> itemType = Watch(ItemType.Armour);
  final Watch<ObjectType> objectType = Watch(objectTypes.first);
  final Watch<EditorDialog> dialog = Watch(EditorDialog.None);
  final mapNameController = TextEditingController();
  final Watch<String> error = Watch("");
  List<Character> characters = [];
}

