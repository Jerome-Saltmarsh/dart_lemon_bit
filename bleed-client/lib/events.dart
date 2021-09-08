

import 'package:neuro/instance.dart';
import 'package:neuro/neuro.dart';

class LobbyJoined {}

class GameJoined {}

void dispatch(message){
  announce(message);
}

void on<T>(HandlerFunction<T> function) {
  neuro.handle(function);
}