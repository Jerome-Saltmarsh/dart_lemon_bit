import 'classes.dart';

class GameState {
  final CharacterController characterController = CharacterController();
  bool panningCamera = false;
  final KeyMap keyMap = KeyMap();

  final List<String> letsGo = [
    "Come on!",
    "Let's go!",
    'Follow me!',
  ];

  final List<String> greetings = [
    'Hello',
    'Hi',
    'Greetings',
  ];

  final List<String> waitASecond = ['Wait a second', 'Just a moment'];
}