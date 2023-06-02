// ignore: depend_on_referenced_packages
import 'package:collection/collection.dart';
import 'package:image/image.dart' as image;
import 'package:nonogram_dart/nonogram_dart.dart';

class Colors {
  static const int white = 0xFFFFFFFF;
  static const int black = 0xFF000000;
  static const int transparent = 0x0;

  static bool isPrimary(int? color) {
    if (color == null) {
      return false;
    }
    if (color == white) {
      return false;
    }
    if (image.uint32ToAlpha(color) < 0xFF) {
      return false;
    }
    return true;
  }

  static bool isSecondary(int? color) {
    return !isPrimary(color);
  }
}

int? bwToColor(int? color) {
  if (color == null) {
    return null;
  }
  if (color == 1) {
    return Colors.black;
  }
  return Colors.white;
}

List<int?> convertRow(
  List<int?> values,
  int? Function(int?) converter,
) {
  return values.map((v) => converter(v)).toList();
}

List<List<int?>> convertGrid(
  List<List<int?>> values,
  int? Function(int?) converter,
) {
  return values.map((r) {
    return r.map((v) => converter(v)).toList();
  }).toList();
}

class Stroke {
  final int color;
  final int length;

  const Stroke(this.color, this.length);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other.runtimeType != runtimeType) {
      return false;
    }
    return other is Stroke && other.color == color && other.length == length;
  }

  @override
  int get hashCode => color.hashCode + length.hashCode;

  Stroke.fromJson(Map<String, dynamic> json)
      : color = json['color'],
        length = json['length'];

  Map<String, dynamic> toJson() => {
        'color': color,
        'length': length,
      };
}

class Description {
  final List<Stroke> strokes;

  const Description(this.strokes);

  factory Description.monochrome(List<int> strokes) {
    return Description(strokes.map((s) => Stroke(Colors.black, s)).toList());
  }

  int get length => strokes.length;

  bool get isEmpty => length == 0;

  int get sumStrokes {
    return strokes.fold(0, (acc, stroke) => acc + stroke.length);
  }

  int get minLineLength => sumStrokes + length - 1;

  bool solvedBy(Line line) {
    return this == line.toDescription();
  }

  Set<int> get colors => strokes.map((s) => s.color).toSet();

  int colorAt(int i) {
    return strokes[i].color;
  }

  int minSpaceAt(int i) {
    if (i == 0) {
      return 0;
    }
    if (colorAt(i - 1) != colorAt(i)) {
      return 0;
    }
    return 1;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other.runtimeType != runtimeType) {
      return false;
    }
    Function deepEq = const DeepCollectionEquality().equals;
    return other is Description && deepEq(other.strokes, strokes);
  }

  @override
  int get hashCode => strokes.fold(0, (acc, stroke) => acc + stroke.hashCode);

  @override
  String toString() {
    return strokes.map((s) => '{c:${s.color}, l:${s.length}}').toString();
  }

  Description.fromJson(Map<String, dynamic> json)
      : strokes = (json['strokes'] as List<dynamic>)
            .map((e) => Stroke.fromJson(e as Map<String, dynamic>))
            .toList();

  Map<String, dynamic> toJson() => {
        'strokes': strokes.map((e) => e.toJson()).toList(),
      };
}
