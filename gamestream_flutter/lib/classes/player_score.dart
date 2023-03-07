

class PlayerScore {
  final int id;
  final String name;
  int credits;

  PlayerScore({required this.id, required this.name, required this.credits});

  static int compare(PlayerScore a, PlayerScore b){
    if (a.credits < b.credits) return 1;
    if (a.credits > b.credits) return -1;
    return 0;
  }
}