import 'package:gamestream_ws/amulet.dart';

class TalkOption {
  final String text;
  final Function(AmuletPlayer player) action;
  const TalkOption(this.text, this.action);
}