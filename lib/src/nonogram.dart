import 'package:nonogram_dart/src/description.dart';

abstract class Line extends Iterable<int?> {
  const Line();

  int? get(int i);
  void set(int i, int? color);

  Set<int> get fixed {
    return Iterable<int>.generate(length).where((i) => get(i) != null).toSet();
  }

  bool get filledOut => fixed.length == length;

  @override
  Iterator<int?> get iterator => LineIterator(this);

  void merge(Line other) {
    for (var i = 0; i < length; i++) {
      if (get(i) != other.get(i)) {
        set(i, null);
      }
    }
  }

  Description toDescription({bool returnIfNull = true}) {
    if (isEmpty) {
      return const Description([]);
    }

    List<Stroke> strokes = [];
    int? currentColor = first;
    int strokeLength = 0;
    for (var color in this) {
      if (currentColor != color) {
        if (currentColor != null && currentColor != NgColors.spaceColor) {
          strokes.add(Stroke(currentColor, strokeLength));
        }
        currentColor = color;
        strokeLength = 0;
      }
      if (returnIfNull && color == null) {
        return Description(strokes);
      }
      strokeLength++;
    }
    if (currentColor != null && currentColor != NgColors.spaceColor) {
      strokes.add(Stroke(currentColor, strokeLength));
    }

    return Description(strokes);
  }
}

class ListLine extends Line {
  final List<int?> _values;
  late final Set<int> _fixed;

  ListLine(this._values) {
    _fixed =
        Iterable<int>.generate(length).where((i) => get(i) != null).toSet();
  }

  @override
  int? get(int i) {
    return _values[i];
  }

  @override
  void set(int i, int? color) {
    if (color != null) {
      _fixed.add(i);
    } else {
      _fixed.remove(i);
    }
    _values[i] = color;
  }

  @override
  Set<int> get fixed => _fixed;

  @override
  int get length {
    return _values.length;
  }
}

class LineIterator with Iterator<int?> {
  final Line line;
  var _i = 0;

  LineIterator(this.line);

  @override
  int? get current => line.get(_i - 1);

  @override
  bool moveNext() {
    if (_i < line.length) {
      _i++;
      return true;
    }
    return false;
  }
}

class Row extends Line {
  final int _index;
  final Grid _grid;

  const Row(this._grid, this._index);

  @override
  int? get(int i) {
    return _grid.get(_index, i);
  }

  @override
  void set(int i, int? color) {
    _grid.set(_index, i, color);
  }

  @override
  int get length {
    return _grid.width;
  }
}

class Column extends Line {
  final int _index;
  final Grid _grid;

  const Column(this._grid, this._index);

  @override
  int? get(int i) {
    return _grid.get(i, _index);
  }

  @override
  void set(int i, int? color) {
    _grid.set(i, _index, color);
  }

  @override
  int get length {
    return _grid.height;
  }
}

class Grid extends Iterable<List<int?>> {
  final List<List<int?>> _rows;

  const Grid(this._rows);

  factory Grid.empty({required int width, required int height}) {
    final rows = List.generate(height, (r) {
      List<int?> row = List.filled(width, null);
      return row;
    });
    return Grid(rows);
  }

  Line getRow(int i) {
    return Row(this, i);
  }

  Line getColumn(int i) {
    return Column(this, i);
  }

  int? get(int row, int column) {
    return _rows[row][column];
  }

  void set(int row, int column, int? color) {
    _rows[row][column] = color;
  }

  int get height => _rows.length;

  int get width => height > 0 ? _rows[0].length : 0;

  bool get filledOut {
    for (var i = 0; i < height; i++) {
      if (!getRow(i).filledOut) {
        return false;
      }
    }
    return true;
  }

  @override
  Iterator<List<int?>> get iterator => _rows.iterator;

  Grid copy() {
    final copy = [
      for (var row in _rows) [...row]
    ];
    return Grid(copy);
  }
}

class Nonogram {
  final List<Description> rows;
  final List<Description> columns;

  const Nonogram(this.rows, this.columns);

  factory Nonogram.monochrome(List<List<int>> rows, List<List<int>> columns) {
    return Nonogram(
      rows.map((r) => Description.monochrome(r)).toList(),
      columns.map((c) => Description.monochrome(c)).toList(),
    );
  }

  int get height => rows.length;
  int get width => columns.length;

  bool solvedBy(Grid grid) {
    if (grid.height != height || grid.width != width) {
      return false;
    }

    // check rows
    for (var i = 0; i < rows.length; i++) {
      if (!rows[i].solvedBy(grid.getRow(i))) {
        return false;
      }
    }

    //check columns
    for (var i = 0; i < columns.length; i++) {
      if (!columns[i].solvedBy(grid.getColumn(i))) {
        return false;
      }
    }

    return true;
  }
}
