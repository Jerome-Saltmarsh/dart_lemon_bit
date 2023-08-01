
class IsometricOptions {
  var renderHealthBarEnemies = true;
  var renderHealthBarAllies = true;
  var sceneSmokeSourcesSmokeDuration = 250;

  void toggleRenderHealthBarEnemies() {
    renderHealthBarEnemies = !renderHealthBarEnemies;
  }

  void toggleRenderHealthbarAllies(){
    renderHealthBarAllies = !renderHealthBarAllies;
  }
}