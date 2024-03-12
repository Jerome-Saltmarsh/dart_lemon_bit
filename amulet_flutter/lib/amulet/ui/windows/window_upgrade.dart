
import 'package:amulet_flutter/amulet/amulet.dart';
import 'package:amulet_flutter/gamestream/ui.dart';
import 'package:flutter/cupertino.dart';
import 'package:lemon_widgets/lemon_widgets.dart';

class WindowUpgrade extends StatelessWidget {

  final Amulet amulet;

  const WindowUpgrade({super.key, required this.amulet});

  @override
  Widget build(BuildContext context) {

    return buildWatch(amulet.equippedChangedNotifier, (t) {
      return GSContainer(
        child: buildText('UPGRADES'),
      );

    });

  }
}