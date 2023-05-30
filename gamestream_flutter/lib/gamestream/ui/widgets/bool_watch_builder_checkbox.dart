
import 'package:flutter/cupertino.dart';
import 'package:gamestream_flutter/gamestream/games/isometric/game_isometric_ui.dart';
import 'package:gamestream_flutter/library.dart';

class BoolWatchBuilderCheckBox extends StatelessWidget {

  final WatchBool watchBool;

  const BoolWatchBuilderCheckBox({super.key, required this.watchBool});

  @override
  Widget build(BuildContext context) {
    return WatchBuilder(watchBool, GameIsometricUI.buildIconCheckbox);
  }
}