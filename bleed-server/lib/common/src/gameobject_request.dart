
enum GameObjectRequest {
  Add,
  Select,
  Deselect,
  Translate,
  Delete,
  Set_Type,
  Move_To_Mouse,
  Toggle_Collider,
  Toggle_Movable,
  Toggle_Collectable,
}

const gameObjectRequests = GameObjectRequest.values;