
import 'package:bleed_client/state.dart';

import 'enums/Mode.dart';

bool get playMode => mode == Mode.Play;
bool get editMode => mode == Mode.Edit;