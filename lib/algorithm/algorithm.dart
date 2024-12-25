import 'dart:math';

import 'package:wordboard/model/word_board_cell.dart';
import 'package:wordboard/enum/direction.dart';

/// Apply DFS (Depth first search) to build the path for hidden word.
/// Result: A path that contains a list of cells that can be used later to fill
/// the hidden word onto the board.
bool _dfs(
  WordBoardCell currentCell,
  int index,
  String hiddenWord,
  int rows,
  int cols,
  List<WordBoardCell> path,
  // Set<WordBoardCell> visitedCells,
) {
  // End case: all cells are determined, we stop.
  if (index == hiddenWord.length) {
    return true;
  }

  // Mark the current cell
  currentCell.letter = hiddenWord[index];
  path.add(currentCell);
  // visitedCells.add(currentCell);
  print('Current path -> $path');
  // print('Current visited cells -> $visitedCells');

  // Try all directions (up, down, top, left).
  // Shuffle the directions to have random order, to have random direction.
  List<Direction> shuffledDirections = List.from(Direction.values);
  shuffledDirections.shuffle();

  // Pick each direction (up, down, left, right), check until find the next cell.
  for (Direction direction in shuffledDirections) {
    final List<int> delta = direction.delta;
    print('Direction -> $direction');
    final int newRow = currentCell.row + delta[0];
    final int newCol = currentCell.column + delta[1];

    final WordBoardCell nextCell = WordBoardCell(row: newRow, column: newCol);

    // Check bounds and if the cell is already visited.
    bool isCellVisited = path.any((cell) {
      // New row and new column match existing visited cell
      // -> newCell was visited.
      return cell.row == newRow && cell.column == newCol;
    });
    if (newRow >= 0 && // Top bound
        newRow < rows && // Bottom bound
        newCol >= 0 && // Left bound
        newCol < cols && // Right bound
        !isCellVisited) {
      if (_dfs(
          nextCell, index + 1, hiddenWord, rows, cols, path,)) {
        return true; // Stop searching if a valid path is found
      }
    }
  }

  // Backtrack: unmark the cell and remove it from the path.
  currentCell.letter = null;
  path.removeLast();
  // visitedCells.remove(currentCell);
  print('Updated path -> $path');
  // print('Updated visited cells -> $visitedCells');
  return false;
}

/// The algorithm to generate the path that we can use to fill the letters on
/// the board.
List<WordBoardCell> generateHiddenWordPath(
    int rows, int cols, String hiddenWord) {
  // Ensure the board has enough cells to fill the hidden word
  if (hiddenWord.length > rows * cols) {
    throw ArgumentError("The board is too small for the hidden word.");
  }

  final Random random = Random();

  // Generate a random starting cell
  final int startRow = random.nextInt(rows);
  final int startCol = random.nextInt(cols);

  // Initialize visited set
  // final Set<WordBoardCell> visitedCells = {};

  // Path to store the result
  final List<WordBoardCell> path = [];

  // Start DFS from the random cell
  final WordBoardCell startCell = WordBoardCell(row: startRow, column: startCol)
    ..letter = hiddenWord[0];
  if (!_dfs(startCell, 0, hiddenWord, rows, cols, path)) {
    throw Exception("Failed to find a valid path for the hidden word.");
  }

  return path;
}
