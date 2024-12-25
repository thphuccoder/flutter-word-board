import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:wordboard/utils/constants.dart';

/// Get the screen width using the [context].
double getScreenWidth(BuildContext context) {
  return MediaQuery.of(context).size.width;
}

/// Get a random letter from the [alphabet].
String getRandomLetter() {
  final Random random = Random();
  return alphabet[random.nextInt(alphabet.length)];
}

/// Listen to the completion of the build() method (in a widget).
/// This method is normally used when we want to trigger an event right after
/// the first build complete.
void onWidgetBuildDone(Function function) {
  SchedulerBinding.instance.addPostFrameCallback((_) {
    function();
  });
}