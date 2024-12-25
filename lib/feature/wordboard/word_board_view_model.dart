import 'package:flutter/material.dart';
import 'package:wordboard/algorithm/algorithm.dart';
import 'package:wordboard/utils/utils.dart';
import 'package:wordboard/model/word_board_cell.dart';

class WordBoardViewModel extends ChangeNotifier {
  final List<WordBoardCell> _cells = [];
  late double cellSize;
  late int boardRow;
  late int boardColumn;
  late String hiddenWord;

  List<WordBoardCell> get cells => _cells;
  List<WordBoardCell> selectedCells = [];

  // This flag is used to draw the wrong word state on the UI
  bool isShowingWrongWord = false;

  void init(
      {required int boardRow,
      required int boardColumn,
      required double cellSize,
      required String hiddenWord}) {
    this.cellSize = cellSize;
    this.boardRow = boardRow;
    this.boardColumn = boardColumn;
    this.hiddenWord = hiddenWord;
    _createWordBoardCells(
        boardRow: boardRow, boardColumn: boardColumn, hiddenWord: hiddenWord);
    notifyListeners();
  }

  /// Update list of selected cells based on the touch positions.
  /// Then these selected cells will be highlighted on the board
  void updateSelectedCells(Offset touchPosition) {
    // Determine which row and column the touch pointer is
    int row = (touchPosition.dy / cellSize).floor();
    int column = (touchPosition.dx / cellSize).floor();
    // Drag outside the board -> Do nothing
    if (row < 0 || row >= boardRow || column < 0 || column >= boardColumn) {
      return;
    }
    int index = row * boardColumn + column;

    // Only check when the index is invalid
    if (index >= 0 || index < row * column) {
      if (index < boardRow * boardColumn) {
        WordBoardCell currentCell = WordBoardCell(
          row: row,
          column: column,
        )..letter = _cells[index].letter;

        // TODO: If User moves the pointer backward -> Update selected cells

        // Add the current cell to selected list if it has not been added yet
        if (!selectedCells.contains(currentCell)) {
          selectedCells.add(currentCell);
        }

        notifyListeners();
      }
    }
  }

  /// Verify if the word (built by player) is correct or not.
  /// And update the UI states accordingly.
  Future<bool> checkWord() async {
    final String selectedWord = selectedCells
        .map((cell) {
          return cell.letter;
        })
        .toList()
        .join('');

    if (selectedWord != hiddenWord) {
      // Update UI for wrong word state
      isShowingWrongWord = true;
      notifyListeners();
      // Wait 1 seconds before reset the board
      await Future.delayed(const Duration(seconds: 1));
      _clearSelectedCells();
      return false;
    } else {
      // Wait 0.5 seconds before reset the board
      await Future.delayed(const Duration(milliseconds: 500));
      _clearSelectedCells();
      return true;
    }
  }

  void _clearSelectedCells() {
    selectedCells.clear();
    isShowingWrongWord = false;
    notifyListeners();
  }

  /// Create the wordboard, including these steps:
  /// 1. Create a board with all empty cells.
  /// 2. Fill the hidden word first.
  /// 3. Fill random letters on the remaining cells.
  void _createWordBoardCells(
      {required int boardRow,
      required int boardColumn,
      required String hiddenWord}) {
    _cells.clear();
    selectedCells.clear();
    _createEmptyBoardCells(boardRow: boardRow, boardColumn: boardColumn);
    _placeTheHiddenWord(
        boardRow: boardRow, boardColumn: boardColumn, hiddenWord: hiddenWord);
    _fillRemainingCells(boardRow: boardRow, boardColumn: boardColumn);
  }

  /// Create a board with empty cells.
  void _createEmptyBoardCells({
    required int boardRow,
    required int boardColumn,
  }) {
    for (int r = 0; r < boardRow; r++) {
      for (int c = 0; c < boardColumn; c++) {
        _cells.add(WordBoardCell(row: r, column: c));
      }
    }
  }

  /// Place hidden word on the board.
  void _placeTheHiddenWord(
      {required int boardRow,
      required int boardColumn,
      required String hiddenWord}) {
    // Use algorithm to create the path for the hidden word
    List<WordBoardCell> path =
        generateHiddenWordPath(boardRow, boardColumn, hiddenWord);

    for (WordBoardCell cell in path) {
      print(cell);
      int row = cell.row;
      int column = cell.column;
      int cellIndex = row * boardColumn + column;
      _cells[cellIndex].letter = cell.letter;
    }
  }

  /// Fill all remaining cells with random letters.
  void _fillRemainingCells({
    required int boardRow,
    required int boardColumn,
  }) {
    for (int i = 0; i < _cells.length; i++) {
      if (_cells[i].letter == null) {
        _cells[i] = WordBoardCell(
          row: _cells[i].row,
          column: _cells[i].column,
        )..letter = getRandomLetter();
      }
    }
  }
}
