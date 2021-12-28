import 'package:bleed_client/classes/EnvironmentObject.dart';
import 'package:bleed_client/common/Tile.dart';
import 'package:bleed_client/common/enums/ObjectType.dart';

class EditState {
  Tile tile = Tile.Grass;
  EnvironmentObject? selectedObject;
}