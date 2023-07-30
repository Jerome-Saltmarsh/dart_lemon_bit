
import 'package:flutter/cupertino.dart';
import 'package:gamestream_flutter/gamestream/isometric/extensions/src.dart';
import 'package:gamestream_flutter/gamestream/ui/enums/icon_type.dart';
import 'package:gamestream_flutter/isometric.dart';
import 'package:gamestream_flutter/ui/isometric_builder.dart';

class GSCheckBox extends StatelessWidget {
  final bool value;

  GSCheckBox(this.value);

  @override
  Widget build(BuildContext context) => IsometricBuilder(
    builder: (context, isometric) => Container(
          width: 32,
          child: isometric.buildAtlasIconType(value ? IconType.Checkbox_True : IconType.Checkbox_False),
        )
  );

}