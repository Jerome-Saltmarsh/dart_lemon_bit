
import 'package:flutter/cupertino.dart';
import 'package:gamestream_flutter/gamestream/games/isometric/game_isometric_ui.dart';
import 'package:gamestream_flutter/gamestream/ui/enums/icon_type.dart';

class GSCheckBox extends StatelessWidget {
  final bool value;

  GSCheckBox(this.value);

  @override
  Widget build(BuildContext context) => Container(
      width: 32,
      child: GameIsometricUI.buildAtlasIconType(value ? IconType.Checkbox_True : IconType.Checkbox_False),
    );

}