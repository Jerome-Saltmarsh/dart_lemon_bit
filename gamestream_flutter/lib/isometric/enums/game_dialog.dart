import 'package:lemon_watch/watch.dart';

final gameDialog = Watch<GameDialog?>(null);

enum GameDialog {
  Scene_Load,
  Scene_Save,
  Debug,
  Audio_Mixer,
}