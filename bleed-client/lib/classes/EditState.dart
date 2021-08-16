
import 'package:bleed_client/classes/Block.dart';
import 'package:bleed_client/editor/EditMode.dart';
import 'package:bleed_client/editor/EditorTool.dart';

class EditState {
  Block selectedBlock;
  EditMode editMode = EditMode.Translate;
  EditorTool tool = EditorTool.Block;
}