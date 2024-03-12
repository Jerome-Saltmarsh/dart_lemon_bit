
import 'package:flutter/cupertino.dart';
import 'package:lemon_watch/src.dart';
import 'package:amulet_flutter/isometric/ui/widgets/isometric_builder.dart';

class BoolWatchBuilderCheckBox extends StatelessWidget {

  final WatchBool watchBool;

  const BoolWatchBuilderCheckBox({super.key, required this.watchBool});

  @override
  Widget build(BuildContext context) => IsometricBuilder(
      builder: (context, isometric) =>
          WatchBuilder(watchBool, isometric.ui.buildIconCheckbox)
    );
}