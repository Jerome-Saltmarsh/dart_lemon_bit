
enum GameStatus {
  None,
  Awaiting_Players,
  Select_Character,
  Counting_Down,
  In_Progress,
  Finished,
}

const gameStatuses = GameStatus.values;