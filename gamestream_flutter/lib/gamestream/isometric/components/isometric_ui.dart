import 'package:gamestream_flutter/gamestream/isometric/enums/dialog_type.dart';
import 'package:gamestream_flutter/library.dart';

class IsometricUI {
  final hoverDialogType = Watch(DialogType.None);


  bool get hoverDialogIsInventory => hoverDialogType.value == DialogType.Inventory;
  bool get hoverDialogDialogIsTrade => hoverDialogType.value == DialogType.Trade;


  void clearMouseOverDialogType() =>
      hoverDialogType.value = DialogType.None;

  void clearHoverDialogType() {
    hoverDialogType.value = DialogType.None;
  }

}