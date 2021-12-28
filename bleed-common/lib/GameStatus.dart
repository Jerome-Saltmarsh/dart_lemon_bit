
enum GameStatus {
  None,
  Awaiting_Players,
  In_Progress,
  Finished,
}

final List<GameStatus> gameStatuses = GameStatus.values;