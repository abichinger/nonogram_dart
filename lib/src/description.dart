import 'package:collection/collection.dart';
import 'package:nonogram_dart/nonogram_dart.dart';

class NgColors {
  static const int spaceColor = 0;
  static const int black = 1;
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
}

class Description {
  final List<Stroke> strokes;

  const Description(this.strokes);

  factory Description.monochrome(List<int> strokes) {
    return Description(strokes.map((s) => Stroke(NgColors.black, s)).toList());
  }

  int get length => strokes.length;

  int get sumStrokes {
    return strokes.fold(0, (acc, stroke) => acc + stroke.length);
  }

  int get minLineLength => sumStrokes + length - 1;

  bool solvedBy(Line line) {
    return this == line.toDescription();
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
}
