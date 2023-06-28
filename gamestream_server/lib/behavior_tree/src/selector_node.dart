import 'behavior_node.dart';

class SelectorNode implements BehaviorNode {
  final List<BehaviorNode> children;

  SelectorNode(this.children);

  @override
  bool execute() {
    for (var child in children) {
      if (child.execute()) {
        return true;
      }
    }
    return false;
  }
}
