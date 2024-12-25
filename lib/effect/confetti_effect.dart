import 'package:flutter/cupertino.dart';
import 'package:flutter_confetti/flutter_confetti.dart';

void showConfettiEffect(BuildContext context) {
  Confetti.launch(
    context,
    options: const ConfettiOptions(
        // TODO: Can configure these numbers in constants or settings
        particleCount: 300,
        spread: 70,
        y: 0.6),
  );
}
