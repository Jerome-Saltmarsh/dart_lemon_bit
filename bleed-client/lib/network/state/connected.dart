import 'package:lemon_watch/watch.dart';

enum Connection {
  None,
  Connecting,
  Connected,
  Done,
  Error,
}

final Watch<Connection> connection = Watch(Connection.None);

bool get connected => connection.value == Connection.Connected;
bool get connecting => connection.value == Connection.Connecting;