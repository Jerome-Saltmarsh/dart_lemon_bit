const nodeSize = 48.0;
const nodeSizeHalf = 24.0;
const nodeHeight = 24.0;
const nodeHeightHalf = 12.0;

double convertIndexZToPosition(int z){
  return z * nodeSizeHalf;
}

double convertIndexRowToPosition(int row){
  return row * nodeSize;
}

double convertIndexColumnToPosition(int column){
  return column * nodeSize;
}