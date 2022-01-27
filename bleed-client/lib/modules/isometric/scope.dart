
import 'package:bleed_client/modules/isometric/properties.dart';
import 'package:bleed_client/modules/isometric/state.dart';

import '../modules.dart';

class IsometricScope {
  IsometricState get state => modules.isometric.state;
  IsometricProperties get properties => modules.isometric.properties;
}