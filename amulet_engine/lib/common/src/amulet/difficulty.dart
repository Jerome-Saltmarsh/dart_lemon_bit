
enum Difficulty {
  Normal(ratio: 1.0),
  Hard(ratio: 1.3),
  Expert(ratio: 1.61);

  final double ratio;
  const Difficulty({required this.ratio});
}