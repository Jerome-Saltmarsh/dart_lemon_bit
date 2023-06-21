
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:gamestream_flutter/game_style.dart';
import 'package:gamestream_flutter/gamestream/isometric/enums/dialog_type.dart';
import 'package:gamestream_flutter/instances/gamestream.dart';

class GSDialog extends StatefulWidget {

  final Widget child;

  const GSDialog({super.key, required this.child});

  @override
  State<GSDialog> createState() => _GSDialogState();
}

class _GSDialogState extends State<GSDialog> {

  @override
  void dispose() {
    super.dispose();
    gamestream.isometric.ui.hoverDialogType.value = DialogType.None;
  }

  @override
  Widget build(BuildContext context) => MouseRegion(
    onEnter: (PointerEnterEvent event) {
      gamestream.isometric.ui.hoverDialogType.value = DialogType.UI_Control;
    },
    onExit: (PointerExitEvent event) {
      gamestream.isometric.ui.hoverDialogType.value = DialogType.None;
    },
    child: widget.child,
  );
}