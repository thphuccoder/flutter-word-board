import 'package:flutter/material.dart';
import 'package:wordboard/feature/wordboard/word_board_view_model.dart';
import 'package:wordboard/utils/constants.dart';
import 'package:wordboard/effect/confetti_effect.dart';
import 'package:wordboard/utils/utils.dart';
import 'package:wordboard/model/word_board_cell.dart';

class WordBoard extends StatefulWidget {
  const WordBoard({super.key});

  @override
  State<WordBoard> createState() => _WordBoardState();
}

class _WordBoardState extends State<WordBoard> {
  WordBoardViewModel workBoardViewModel = WordBoardViewModel();
  TextEditingController controller =
      TextEditingController(text: defaultHiddenWord);
  double scale = 0;

  @override
  void initState() {
    super.initState();
    onWidgetBuildDone(() {
      _generateWordBoard();
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
        listenable: workBoardViewModel,
        builder: (BuildContext context, Widget? widget) {
          if (workBoardViewModel.cells.isEmpty) {
            return const CircularProgressIndicator();
          }

          final double screenWidth = getScreenWidth(context);
          final boardWidth = (screenWidth - wordBoardMargin * 2);
          final double cellWidth = boardWidth / wordBoardColumn;
          final double boardHeight = cellWidth * wordBoardRow;

          return Column(
            // spacing: 20,
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedScale(
                scale: scale,
                duration: const Duration(seconds: 1),
                child: GestureDetector(
                    onPanStart: _onPanStart,
                    onPanUpdate: _onPanUpdate,
                    onPanEnd: _onPanEnd,
                    child: CustomPaint(
                      size: Size(boardWidth, boardHeight),
                      painter: WordBoardPainter(
                        boardWidth: boardWidth,
                        boardHeight: boardHeight,
                        wordBoardViewModel: workBoardViewModel,
                      ),
                    )),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                child: TextField(
                  controller: controller,
                  onChanged: (text) {},
                  enabled: true,
                  decoration:
                      const InputDecoration(hintText: 'Enter a hidden word...'),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: ElevatedButton(
                    onPressed: () {
                      _generateWordBoard(hiddenWord: controller.text);
                    },
                    child: const Text('Generate Board')),
              )
            ],
          );
        });
  }

  /// User starts to tap on the board.
  void _onPanStart(DragStartDetails details) {
    RenderBox box = context.findRenderObject() as RenderBox;
    Offset localPosition = box.globalToLocal(details.globalPosition);

    workBoardViewModel.updateSelectedCells(localPosition);
  }

  /// User moves across the cell(s).
  void _onPanUpdate(DragUpdateDetails details) {
    RenderBox box = context.findRenderObject() as RenderBox;
    Offset localPosition = box.globalToLocal(details.globalPosition);

    workBoardViewModel.updateSelectedCells(localPosition);
  }

  /// User releases the touch.
  Future<void> _onPanEnd(DragEndDetails details) async {
    // User releases the touch/drag -> Check the selected word
    bool isCorrect = await workBoardViewModel.checkWord();
    if (isCorrect) {
      if (mounted) {
        showConfettiEffect(context);
      }
    }
  }

  Future<void> _generateWordBoard(
      {String hiddenWord = defaultHiddenWord}) async {
    setState(() {
      scale = 0;
    });
    final double screenWidth = getScreenWidth(context);
    final double boardWidth = (screenWidth - wordBoardMargin * 2);
    final double cellSize = boardWidth / wordBoardColumn;
    // Delay to visually see the scale effect.
    await Future.delayed(const Duration(milliseconds: 300));
    workBoardViewModel.init(
        boardRow: wordBoardRow,
        boardColumn: wordBoardColumn,
        cellSize: cellSize,
        hiddenWord: hiddenWord.toUpperCase());
    setState(() {
      scale = 1;
    });
  }
}

class WordBoardPainter extends CustomPainter {
  final double boardWidth;
  final double boardHeight;
  final WordBoardViewModel wordBoardViewModel;

  WordBoardPainter({
    required this.boardWidth,
    required this.boardHeight,
    required this.wordBoardViewModel,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cellSize = size.width / wordBoardColumn;
    drawConnectionPath(canvas, cellSize);
    drawBoardCells(canvas, cellSize);
  }

  void drawBoardCells(Canvas canvas, double cellSize) {
    Paint cellPaint = Paint()..color = Colors.white;
    Paint cellBorderPaint = Paint()
      ..color = Colors.black45
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;
    Paint highlightedCellPaint = Paint()
      ..color =
          wordBoardViewModel.isShowingWrongWord ? Colors.red : Colors.yellow;

    // Draw the board's cells
    for (int row = 0; row < wordBoardRow; row++) {
      for (int column = 0; column < wordBoardColumn; column++) {
        int index = row * wordBoardColumn + column;
        final String letter = wordBoardViewModel.cells[index].letter ?? '';
        final WordBoardCell currentCell =
            WordBoardCell(row: row, column: column)..letter = letter;

        double cellRectSize = wordBoardViewModel.isShowingWrongWord
            ? cellSize - cellMargin
            : cellSize - cellMargin * 2;
        Rect cellRect = Rect.fromLTWH(column * cellSize + cellMargin,
            row * cellSize + cellMargin, cellRectSize, cellRectSize);
        RRect cellRRect = RRect.fromRectAndRadius(
            cellRect, const Radius.circular(cellBorderRadius));

        // Highlight cell if the cell is in highlightedCells.
        if (wordBoardViewModel.selectedCells.contains(currentCell)) {
          canvas.drawRRect(cellRRect, highlightedCellPaint);
        } else {
          canvas.drawRRect(cellRRect, cellPaint);
        }
        canvas.drawRRect(cellRRect, cellBorderPaint);

        // Draw the letter
        TextPainter textPainter = TextPainter(
            text: TextSpan(
              text: letter,
              style: TextStyle(
                color: Colors.black,
                fontSize: cellSize * 0.45,
                fontWeight: FontWeight.w400,
              ),
            ),
            textAlign: TextAlign.center,
            textDirection: TextDirection.ltr);
        textPainter.layout();
        Offset textOffset = Offset(
          cellRect.center.dx - textPainter.width / 2,
          cellRect.center.dy - textPainter.height / 2,
        );
        textPainter.paint(canvas, textOffset);
      }
    }
  }

  void drawConnectionPath(Canvas canvas, double cellSize) {
    Paint connectPathPaint = Paint()
      ..color = Colors.green
      ..strokeWidth = connectedPathWidth
      ..style = PaintingStyle.stroke;

    Paint connectCirclePaint = Paint()
      ..color = Colors.green
      ..style = PaintingStyle.fill;
    // Draw connect path.
    if (wordBoardViewModel.selectedCells.isNotEmpty) {
      double cellCenterX =
          wordBoardViewModel.selectedCells[0].column * cellSize + cellSize / 2;
      double cellCenterY =
          wordBoardViewModel.selectedCells[0].row * cellSize + cellSize / 2;
      // Draw a circle at the center of the cell.
      canvas.drawCircle(Offset(cellCenterX, cellCenterY), connectedDotRadius,
          connectCirclePaint);
      Path pathLine = Path()..moveTo(cellCenterX, cellCenterY);
      for (int i = 1; i < wordBoardViewModel.selectedCells.length; i++) {
        cellCenterX = wordBoardViewModel.selectedCells[i].column * cellSize +
            cellSize / 2;
        cellCenterY =
            wordBoardViewModel.selectedCells[i].row * cellSize + cellSize / 2;
        // Draw a circle at the center of the cell.
        canvas.drawCircle(Offset(cellCenterX, cellCenterY), connectedDotRadius,
            connectCirclePaint);
        pathLine.lineTo(cellCenterX, cellCenterY);
      }

      canvas.drawPath(pathLine, connectPathPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
