
import 'package:lemon_watch/watch.dart';

final _UI ui = _UI();

enum Dialogs {
  Games,
  Account,
  Confirm_Logout,
}

class _UI {
  final Watch<Dialogs> dialog = Watch(Dialogs.Games);
}