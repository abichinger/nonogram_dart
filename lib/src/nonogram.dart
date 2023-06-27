import 'dart:typed_data';

import 'package:collection/collection.dart';
import 'package:crypto/crypto.dart';
import 'package:image/image.dart' as image;
import 'package:nonogram_dart/nonogram_dart.dart';

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

  Line get reversed => ReversedLine(this);

  Description toDescription({
    bool returnIfNull = true,
    bool Function(int? color)? isPrimary,
  }) {
    if (isEmpty) {
      return const Description([]);
    }

    List<Stroke> strokes = [];
    int? currentColor = first;
    int strokeLength = 0;
    for (var color in this) {
      if (returnIfNull && color == null) {
        return Description(strokes);
      }
      if (currentColor != color) {
        if (currentColor != null &&
            (isPrimary ?? Colors.isPrimary)(currentColor)) {
          strokes.add(Stroke(currentColor, strokeLength));
        }
        currentColor = color;
        strokeLength = 0;
      }
      strokeLength++;
    }
    if (currentColor != null && (isPrimary ?? Colors.isPrimary)(currentColor)) {
      strokes.add(Stroke(currentColor, strokeLength));
    }

    return Description(strokes);
  }

  @override
  String toString() {
    return map((color) {
      if (color == null) {
        return "n";
      }
      if (color == Colors.white) {
        return "□";
      }
      return "■";
    }).join(" ");
  }
}

class ReversedLine extends Line {
  final Line line;

  ReversedLine(this.line);

  int _translate(int i) {
    return length - 1 - i;
  }

  @override
  int? get(int i) {
    return line.get(_translate(i));
  }

  @override
  void set(int i, int? color) {
    line.set(_translate(i), color);
  }

  @override
  int get length {
    return line.length;
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
    return Grid.filled(width: width, height: height, color: null);
  }

  factory Grid.filled({required int width, required int height, int? color}) {
    final rows = List.generate(height, (r) {
      List<int?> row = List.filled(width, color);
      return row;
    });
    return Grid(rows);
  }

  factory Grid.fromPng(Uint8List imageData, {Map<int?, int?>? colorMapping}) {
    final img = image.decodePng(imageData);
    if (img == null) {
      throw 'failed to decode image';
    }

    return Grid.fromImage(img, colorMapping: colorMapping);
  }

  factory Grid.fromImage(image.Image img, {Map<int?, int?>? colorMapping}) {
    final grid = Grid.empty(width: img.width, height: img.height);
    for (int x = 0; x < img.width; x++) {
      for (int y = 0; y < img.height; y++) {
        final pixel = img.getPixelSafe(x, y);
        final c = image.rgbaToUint32(
          pixel.b.toInt(),
          pixel.g.toInt(),
          pixel.r.toInt(),
          pixel.a.toInt(),
        );
        grid.set(
          y,
          x,
          colorMapping?.containsKey(c) == true ? colorMapping![c] : c,
        );
      }
    }
    return grid;
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

  Nonogram toNonogram({bool Function(int? color)? isPrimary}) {
    final rows = List.generate(
      height,
      (i) => getRow(i).toDescription(returnIfNull: false, isPrimary: isPrimary),
    );
    final columns = List.generate(
      width,
      (i) =>
          getColumn(i).toDescription(returnIfNull: false, isPrimary: isPrimary),
    );
    return Nonogram(rows, columns);
  }

  @override
  String toString() {
    return List.generate(height, (i) => getRow(i).toString()).join("\n");
  }

  image.Image toImage({
    Map<int?, int?>? colorMapping,
    int nullColor = Colors.white,
  }) {
    final img = image.Image(width: width, height: height, numChannels: 4);

    for (int x = 0; x < img.width; x++) {
      for (int y = 0; y < img.height; y++) {
        var c = get(y, x);
        c = colorMapping?[c] ?? c ?? nullColor;
        image.drawPixel(
            img,
            x,
            y,
            image.ColorRgba8(
              image.uint32ToBlue(c),
              image.uint32ToGreen(c),
              image.uint32ToRed(c),
              image.uint32ToAlpha(c),
            ));
      }
    }

    return img;
  }

  Uint8List toPng({Map<int?, int?>? colorMapping}) {
    final img = toImage(colorMapping: colorMapping);
    return image.encodePng(img);
  }

  Grid toMonochrome({bool Function(int? color)? isPrimary}) {
    final grid = Grid.empty(width: width, height: height);
    final p = isPrimary ?? Colors.isPrimary;

    for (int x = 0; x < width; x++) {
      for (int y = 0; y < height; y++) {
        final c = get(y, x);
        if (p(c)) {
          grid.set(y, x, Colors.black);
        } else {
          grid.set(y, x, Colors.white);
        }
      }
    }
    return grid;
  }

  String getHash() {
    final img = toImage();
    final bytes = img.getBytes(order: image.ChannelOrder.argb);
    return sha256.convert(bytes).toString();
  }

  List<Solution> solutions() {
    final nonogram = toNonogram();
    final solver = GuessingSolver.empty(nonogram);
    return solver.toList();
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

  factory Nonogram.empty({required int width, required int height}) {
    return Nonogram(
      List.generate(height, (index) => const Description([])),
      List.generate(width, (index) => const Description([])),
    );
  }

  int get height => rows.length;
  int get width => columns.length;
  Set<int> get colors {
    return rows.fold<Set<int>>({}, (s, d) => s..addAll(d.colors));
  }

  int get maxRowSegments {
    return rows.map((d) => d.strokes.length).max;
  }

  int get maxColumnSegments {
    return columns.map((d) => d.strokes.length).max;
  }

  double get filledPercentage {
    double max = (width * height).toDouble();
    int filled = rows.fold(
        0, (acc, d) => acc + d.strokes.fold(0, (acc, s) => acc + s.length));
    return filled / max;
  }

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

  bool isLineSolveable() {
    final solver = LogicalSolver.empty(this);
    final solutions = solver.toList();
    if (solutions.length != 1) {
      return false;
    }
    final solution = solutions[0];
    if (solution.steps.length != width * height) {
      return false;
    }
    return true;
  }
}
