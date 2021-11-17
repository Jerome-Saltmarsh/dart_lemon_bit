
import 'package:bleed_client/classes/EnvironmentObject.dart';
import 'package:bleed_client/common/Tile.dart';
import 'package:bleed_client/common/enums/EnvironmentObjectType.dart';

class EditState {
  Tile tile = Tile.Grass;
  EnvironmentObjectType environmentObjectType = EnvironmentObjectType.House01;
  EnvironmentObject selectedObject;
}