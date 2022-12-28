import 'package:gamestream_flutter/library.dart';

class RendererNodes extends Renderer {
  @override
  void renderFunction() => GameRender.renderCurrentNodeLine();
  @override
  void updateFunction() => GameRender.nodesUpdateFunction();
  @override
  void reset() => GameRender.resetNodes();
  @override
  int getTotal() => GameNodes.nodesTotal;
}
