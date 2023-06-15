
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
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
    gamestream.isometric.clientState.hoverDialogType.value = DialogType.None;
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (PointerEnterEvent event) {
        gamestream.isometric.clientState.hoverDialogType.value = DialogType.UI_Control;
      },
      onExit: (PointerExitEvent event) {
        gamestream.isometric.clientState.hoverDialogType.value = DialogType.None;
      },
      child: widget.child,
    );
  }
}