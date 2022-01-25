
import 'package:bleed_client/classes/Character.dart';
import 'package:bleed_client/classes/EnvironmentObject.dart';
import 'package:bleed_client/common/CharacterType.dart';
import 'package:bleed_client/common/Tile.dart';
import 'package:bleed_client/common/enums/ObjectType.dart';
import 'package:flutter/cupertino.dart';
import 'package:lemon_math/Vector2.dart';
import 'package:lemon_watch/watch.dart';

import 'enums.dart';

class EditorState {
  final Watch<int> startingHour = Watch(12);
  int selectedCollectable = -1;
  bool panning = false;
  bool mouseDragging = false;
  Offset mouseWorldStart = Offset(0, 0);
  final Watch<String> process = Watch("");
  final Watch<Vector2?> selectedObject = Watch(null);
  final Watch<ToolTab> tab = Watch(ToolTab.Tiles);
  final Watch<Tile> tile = Watch(Tile.Grass);
  final Watch<CharacterType> characterType = Watch(CharacterType.Human);
  final Watch<ObjectType> objectType = Watch(objectTypes.first);
  final Watch<EditorDialog> dialog = Watch(EditorDialog.None);
  final mapNameController = TextEditingController();
  List<Character> characters = [];
}