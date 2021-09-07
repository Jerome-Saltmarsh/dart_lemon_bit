
import 'package:bleed_client/classes/Block.dart';
import 'package:bleed_client/editor/EditMode.dart';
import 'package:bleed_client/enums.dart';

class EditState {
  Block selectedBlock;
  EditMode editMode = EditMode.Translate;
  Tile tile = Tile.Grass;
}