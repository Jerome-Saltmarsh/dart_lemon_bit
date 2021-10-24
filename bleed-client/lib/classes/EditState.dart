
import 'package:bleed_client/classes/Block.dart';
import 'package:bleed_client/classes/EnvironmentObject.dart';
import 'package:bleed_client/common/Tile.dart';
import 'package:bleed_client/common/enums/EnvironmentObjectType.dart';
import 'package:bleed_client/editor/EditMode.dart';

class EditState {
  Block selectedBlock;
  EditMode editMode = EditMode.Translate;
  Tile tile = Tile.Grass;
  EnvironmentObjectType environmentObjectType = EnvironmentObjectType.House01;
  EnvironmentObject selectedObject;
}