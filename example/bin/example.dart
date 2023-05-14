import 'package:nonogram_dart/nonogram_dart.dart';

void main(List<String> arguments) {
  final puzzle = Nonogram.monochrome(
    [
      [2],
      [1, 1],
      [1, 1],
      [1, 1],
      [3],
    ],
    [
      [3],
      [1, 1],
      [1, 1],
      [1],
      [3],
    ],
  );

  final solver = GuessingSolver.empty(puzzle);
  final solutions = solver.toList();

  for (final solution in solutions) {
    print(solution.grid.toString());
    print("");
  }
}
