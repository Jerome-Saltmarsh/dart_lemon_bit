import 'package:lemon_watch/watch.dart';

final editToolsEnabled = Watch(true);

void toggleEditToolsEnabled() => editToolsEnabled.value = !editToolsEnabled.value;