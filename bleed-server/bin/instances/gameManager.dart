import '../classes/Game.dart';
import '../classes/GameManager.dart';

GameManager gameManager = GameManager();

List<Game> get games => gameManager.games;
