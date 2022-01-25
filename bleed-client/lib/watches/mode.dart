import 'package:bleed_client/modules/core/enums.dart';

import '../modules.dart';

bool get playMode => core.state.mode.value == Mode.Play;
bool get editMode => core.state.mode.value == Mode.Edit;