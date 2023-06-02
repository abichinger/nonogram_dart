import 'dart:math';

import 'package:image/image.dart';
import 'package:nonogram_dart/src/nonogram.dart';

abstract class GridModifier {
  void modify(GridGenerator g);
}

class RandomPixel extends GridModifier {
  final int n;

  RandomPixel({this.n = 1});

  @override
  void modify(GridGenerator g) {
    var image = g.image;
    for (var i = 0; i < n; i++) {
      image.setPixel(
        g.random(image.width),
        g.random(image.height),
        g.randomColor(),
      );
    }
  }
}

class RandomizeAll extends GridModifier {
  @override
  void modify(GridGenerator g) {
    var image = g.image;
    for (var y = 0; y < image.height; y++) {
      for (var x = 0; x < image.width; x++) {
        image.setPixel(
          x,
          y,
          g.randomColor(),
        );
      }
    }
  }
}

class RandomFill extends GridModifier {
  @override
  void modify(GridGenerator g) {
    fill(g.image, color: g.randomColor());
  }
}

class RandomTriangle extends GridModifier {
  final bool fill;
  final int thickness;

  RandomTriangle(this.fill, {this.thickness = 1});

  @override
  void modify(GridGenerator g) {
    if (fill) {
      fillPolygon(
        g.image,
        vertices: g.randomPointList(3, g.width, g.height),
        color: g.randomColor(),
      );
    } else {
      drawPolygon(
        g.image,
        vertices: g.randomPointList(3, g.width, g.height),
        color: g.randomColor(),
        thickness: thickness,
      );
    }
  }
}

class RandomRect extends GridModifier {
  final bool fill;
  final int thickness;

  RandomRect(this.fill, {this.thickness = 1});

  @override
  void modify(GridGenerator g) {
    if (fill) {
      fillRect(
        g.image,
        x1: g.random(g.width),
        y1: g.random(g.height),
        x2: g.random(g.width),
        y2: g.random(g.height),
        color: g.randomColor(),
      );
    } else {
      drawRect(
        g.image,
        x1: g.random(g.width),
        y1: g.random(g.height),
        x2: g.random(g.width),
        y2: g.random(g.height),
        color: g.randomColor(),
        thickness: thickness,
      );
    }
  }
}

class RandomLine extends GridModifier {
  final int minThickness;
  final int maxThickness;

  RandomLine({this.minThickness = 1, this.maxThickness = 3});

  @override
  void modify(GridGenerator g) {
    drawLine(
      g.image,
      x1: g.random(g.width),
      y1: g.random(g.height),
      x2: g.random(g.width),
      y2: g.random(g.height),
      color: g.randomColor(),
      thickness: g.random(maxThickness + 1, min: minThickness),
    );
  }
}

class RandomStraight extends GridModifier {
  @override
  void modify(GridGenerator g) {
    var horizontal = g.random(2) == 0 ? true : false;

    if (horizontal) {
      final y = g.random(g.height);

      drawLine(
        g.image,
        x1: g.random(g.width),
        y1: y,
        x2: g.random(g.width),
        y2: y,
        color: g.randomColor(),
      );
    } else {
      final x = g.random(g.width);

      drawLine(
        g.image,
        x1: x,
        y1: g.random(g.height),
        x2: x,
        y2: g.random(g.height),
        color: g.randomColor(),
      );
    }
  }
}

class GridGenerator {
  final int width;
  final int height;
  final Set<int> colors;
  final int? seed;
  late Random _random;
  late Image image;

  GridGenerator({
    required this.width,
    required this.height,
    required this.colors,
    this.seed,
  }) {
    image = Image(width: width, height: height, numChannels: 4);
    _random = Random(seed);
  }

  Color randomColor() {
    int rgba = colors.elementAt(_random.nextInt(colors.length));
    return ColorRgba8(
      uint32ToBlue(rgba),
      uint32ToGreen(rgba),
      uint32ToRed(rgba),
      uint32ToAlpha(rgba),
    );
  }

  int random(int max, {int min = 0}) {
    return _random.nextInt(max - min) + min;
  }

  List<int> randomList(int length, int max, {int min = 0}) {
    return List.generate(length, (index) => random(max, min: min));
  }

  Point randomPoint(int xMax, int yMax, {int minX = 0, int minY = 0}) {
    return Point(
      random(xMax, min: minX),
      random(yMax, min: minY),
    );
  }

  List<Point> randomPointList(int length, int xMax, int yMax,
      {int minX = 0, int minY = 0}) {
    return List.generate(
        length, (index) => randomPoint(xMax, yMax, minX: minX, minY: minY));
  }

  void apply(List<GridModifier> modifiers) {
    for (var m in modifiers) {
      m.modify(this);
    }
  }

  void applyN(int n, List<GridModifier> modifiers) {
    for (var i = 0; i < n; i++) {
      var m = modifiers[random(modifiers.length)];
      apply([m]);
    }
  }

  Grid getGrid() {
    return Grid.fromImage(image);
  }
}
