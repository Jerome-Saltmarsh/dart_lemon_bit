
enum GameObjectRequest {
  Add,
  Select,
  Deselect,
  Translate,
  Delete,
  Set_Type,
  Move_To_Mouse,
  Toggle_Collider,
  Toggle_Fixed,
  Toggle_Collectable,
  Toggle_Physical,
  Toggle_Persistable,
}

const gameObjectRequests = GameObjectRequest.values;