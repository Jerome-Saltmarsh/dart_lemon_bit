
import 'dart:math';

Random random = Random();

double randomBetween(num a, num b){
  return (random.nextDouble() * (b - a)) + a;
}