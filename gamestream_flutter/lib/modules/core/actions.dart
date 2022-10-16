import 'package:bleed_common/GameType.dart';
import 'package:gamestream_flutter/servers.dart';
import 'package:gamestream_flutter/website/website.dart';

void connectToGameDarkAge() => connectToGame(GameType.Dark_Age);

void connectToGameEditor() => connectToGame(GameType.Editor);

void connectToGameWaves() => connectToGame(GameType.Waves);

void connectToGameSkirmish() => connectToGame(GameType.Skirmish);

void connectToGame(int gameType, [String message = ""]) =>
  connectToRegion(Website.region.value, '${gameType} $message');