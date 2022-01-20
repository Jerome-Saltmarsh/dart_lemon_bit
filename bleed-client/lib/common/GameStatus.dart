
enum GameStatus {
  Awaiting_Players,
  Counting_Down,
  In_Progress,
  Finished,
}

final List<GameStatus> gameStatuses = GameStatus.values;