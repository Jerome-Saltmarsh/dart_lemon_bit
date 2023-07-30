
import 'package:flutter/cupertino.dart';
import 'package:gamestream_flutter/gamestream/isometric/extensions/src.dart';
import 'package:gamestream_flutter/library.dart';
import 'package:gamestream_flutter/ui/isometric_builder.dart';

class BoolWatchBuilderCheckBox extends StatelessWidget {

  final WatchBool watchBool;

  const BoolWatchBuilderCheckBox({super.key, required this.watchBool});

  @override
  Widget build(BuildContext context) => IsometricBuilder(
      builder: (context, isometric) =>
          WatchBuilder(watchBool, isometric.buildIconCheckbox)
    );
}