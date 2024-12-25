import 'package:flutter/material.dart';
import 'package:wordboard/feature/wordboard/word_board.dart';

class WordBoardGame extends StatelessWidget {
  const WordBoardGame({super.key});

  @override
  Widget build(BuildContext context) {
    return const Material(
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            WordBoard()
          ],
        ),
      )
    );
  }
}
