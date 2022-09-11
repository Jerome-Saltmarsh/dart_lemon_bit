const nodeSize = 48.0;
const nodeSizeHalf = 24.0;
const nodeHeight = 24.0;
const nodeHeightHalf = 12.0;

double convertIndexToZ(int z){
  return z * nodeSizeHalf;
}

double convertIndexToX(int row){
  return row * nodeSize;
}

double convertIndexToY(int column){
  return column * nodeSize;
}