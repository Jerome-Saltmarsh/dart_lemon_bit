import 'package:bleed_client/core/module.dart';
import 'package:bleed_client/enums/Mode.dart';

bool get playMode => core.state.mode.value == Mode.Play;
bool get editMode => core.state.mode.value == Mode.Edit;