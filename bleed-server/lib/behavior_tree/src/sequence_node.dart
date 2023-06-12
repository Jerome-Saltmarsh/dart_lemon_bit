import 'behavior_node.dart';

class SequenceNode implements BehaviorNode {
  final List<BehaviorNode> children;

  SequenceNode(this.children);

  @override
  bool execute() {
    for (var child in children) {
      if (!child.execute()) {
        return false;
      }
    }
    return true;
  }
}
