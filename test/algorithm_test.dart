import 'package:flutter_test/flutter_test.dart';
import 'package:wordboard/algorithm/algorithm.dart';
import 'package:wordboard/model/word_board_cell.dart';

void main() {
  group('generateHiddenWordPath', () {
    test('Test hidden word fits within a small board', () {
      int rows = 3;
      int cols = 3;
      String hiddenWord = "CAT";

      List<WordBoardCell> path = generateHiddenWordPath(rows, cols, hiddenWord);

      expect(path.length, hiddenWord.length);

      for (int i = 0; i < hiddenWord.length; i++) {
        expect(path[i].letter, hiddenWord[i]);
      }
    });

    test('Test hidden word fills a larger board', () {
      int rows = 5;
      int cols = 5;
      String hiddenWord = "HELLO";

      List<WordBoardCell> path = generateHiddenWordPath(rows, cols, hiddenWord);

      expect(path.length, hiddenWord.length);

      for (int i = 0; i < hiddenWord.length; i++) {
        expect(path[i].letter, hiddenWord[i]);
      }
    });

    test('Test hidden word with single letter', () {
      int rows = 2;
      int cols = 2;
      String hiddenWord = "A";

      List<WordBoardCell> path = generateHiddenWordPath(rows, cols, hiddenWord);

      expect(path.length, hiddenWord.length);
      expect(path.first.letter, hiddenWord);
    });

    test('Test hidden word matches correct cell positions', () {
      int rows = 4;
      int cols = 4;
      String hiddenWord = "TEST";

      List<WordBoardCell> path = generateHiddenWordPath(rows, cols, hiddenWord);

      for (int i = 1; i < path.length; i++) {
        int dx = (path[i].row - path[i - 1].row).abs();
        int dy = (path[i].column - path[i - 1].column).abs();
        // Ensure each cell is adjacent
        expect(dx + dy, equals(1));
      }
    });

    test('Test longer hidden word across larger board', () {
      int rows = 10;
      int cols = 10;
      String hiddenWord = "CONVERSATIONAL";

      List<WordBoardCell> path = generateHiddenWordPath(rows, cols, hiddenWord);

      expect(path.length, hiddenWord.length);

      for (int i = 0; i < hiddenWord.length; i++) {
        expect(path[i].letter, hiddenWord[i]);
      }
    });

    test('Throws error when hidden word exceeds board size', () {
      int rows = 2;
      int cols = 2;
      String hiddenWord = "TOOLONG";

      expect(
              () => generateHiddenWordPath(rows, cols, hiddenWord),
          throwsA(isA<ArgumentError>()));
    });

    test('Path has no duplicate cells', () {
      int rows = 5;
      int cols = 5;
      String hiddenWord = "UNIQUE";

      List<WordBoardCell> path = generateHiddenWordPath(rows, cols, hiddenWord);

      final visitedCells = <WordBoardCell>{};
      for (final cell in path) {
        expect(visitedCells.contains(cell), isFalse);
        visitedCells.add(cell);
      }
    });

    test('Hidden word with all same letters', () {
      int rows = 3;
      int cols = 3;
      String hiddenWord = "AAA";

      List<WordBoardCell> path = generateHiddenWordPath(rows, cols, hiddenWord);

      expect(path.length, hiddenWord.length);

      for (int i = 0; i < hiddenWord.length; i++) {
        expect(path[i].letter, "A");
      }
    });
  });
}