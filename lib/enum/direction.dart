enum Direction {
  up,
  down,
  left,
  right;

  // Get the row and column delta for each direction
  List<int> get delta {
    switch (this) {
      case Direction.up:
        return [0, -1];
      case Direction.down:
        return [0, 1];
      case Direction.left:
        return [-1, 0];
      case Direction.right:
        return [1, 0];
    }
  }
}