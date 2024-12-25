class WordBoardCell {
  final int column;
  final int row;
  String? letter;

  WordBoardCell({this.column = -1, this.row = -1});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WordBoardCell &&
          runtimeType == other.runtimeType &&
          (column != -1 && row != -1) &&
          (other.column != -1 && other.row != -1) &&
          column == other.column &&
          row == other.row &&
          letter == other.letter;

  @override
  int get hashCode => column.hashCode ^ row.hashCode ^ letter.hashCode;
  @override
  String toString() {
    return '($row, $column) -> $letter';
  }
}
