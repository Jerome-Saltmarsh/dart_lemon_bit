
import 'package:flutter/cupertino.dart';
import 'package:amulet_flutter/gamestream/ui/enums/icon_type.dart';
import 'package:amulet_flutter/isometric/ui/widgets/isometric_builder.dart';

class GSCheckBox extends StatelessWidget {
  final bool value;

  GSCheckBox(this.value);

  @override
  Widget build(BuildContext context) => IsometricBuilder(
    builder: (context, isometric) => Container(
          width: 32,
          child: isometric.ui.buildAtlasIconType(value ? IconType.Checkbox_True : IconType.Checkbox_False),
        )
  );

}