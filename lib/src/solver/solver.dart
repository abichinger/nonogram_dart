import 'package:nonogram_dart/src/description.dart';
import 'package:nonogram_dart/src/nonogram.dart';
import 'package:nonogram_dart/src/solver/line_solver.dart';

class Solution {
  final Grid grid;
  final List<Step> steps;

  const Solution(this.grid, this.steps);

  int sweeps() {
    var currentFocus = SolverFocus.rows;
    var count = 1;
    for (var step in steps) {
      if (step.focus == null || step.focus == currentFocus) {
        continue;
      }
      currentFocus = step.focus!;
      count++;
    }
    return count;
  }
}

enum SolverFocus {
  rows,
  columns,
}

abstract class Solver extends Iterable<Solution> {
  final Nonogram nonogram;
  final Grid grid;
  late List<Step> steps;

  Solver(
    this.nonogram,
    this.grid, {
    List<Step>? steps,
  }) {
    this.steps = steps ?? [];
  }

  List<Step> solve();
}

class LogicalSolver extends Solver {
  LogicalSolver(super.nonogram, super.grid, {super.steps});

  factory LogicalSolver.empty(Nonogram nonogram) {
    return LogicalSolver(
        nonogram,
        Grid.empty(
          width: nonogram.width,
          height: nonogram.height,
        ));
  }

  @override
  List<Step> solve() {
    while (true) {
      var stepsStart = steps.length;
      _sweep(
        grid.height,
        (i) => grid.getRow(i),
        (i) => nonogram.rows[i],
        (step, i) => step.copyWith(
          pos: Position(i, step.i),
          descriptionIndex: i,
          focus: SolverFocus.rows,
        ),
      );
      _sweep(
        grid.width,
        (i) => grid.getColumn(i),
        (i) => nonogram.columns[i],
        (step, i) => step.copyWith(
          pos: Position(step.i, i),
          descriptionIndex: i,
          focus: SolverFocus.columns,
        ),
      );

      // stop if solver is stalling
      if (stepsStart == steps.length) {
        break;
      }
    }
    return steps;
  }

  void _sweep(
    int n,
    Line Function(int i) getLine,
    Description Function(int i) getDescription,
    Step Function(Step step, int i) copyStep,
  ) {
    for (var i = 0; i < n; i++) {
      final line = getLine(i);
      if (line.filledOut) {
        continue;
      }
      final lineSolver = PermutationSolver(line, getDescription(i));
      for (var step in lineSolver.getSteps()) {
        line.set(step.i, step.color);
        steps.add(copyStep(step, i));
      }
    }
  }

  @override
  Iterator<Solution> get iterator {
    solve();

    if (!nonogram.solvedBy(grid)) {
      return <Solution>[].iterator;
    }

    return [Solution(grid, steps)].iterator;
  }
}

class GuessingSolver extends Solver {
  GuessingSolver(super.nonogram, super.grid, {super.steps});

  factory GuessingSolver.empty(Nonogram nonogram) {
    return GuessingSolver(
        nonogram,
        Grid.empty(
          width: nonogram.width,
          height: nonogram.height,
        ));
  }

  @override
  Iterator<Solution> get iterator => GuessingSolverIterator(
      LogicalSolver(nonogram, grid, steps: steps),
      nonogram.colors..add(Colors.white));

  @override
  List<Step> solve() {
    var iter = iterator..moveNext();
    var solver = iter.current;
    steps = solver.steps;
    return steps;
  }
}

class GuessingSolverIterator with Iterator<Solution> {
  late final List<LogicalSolver> _solvers = [];
  late Solver _solver;
  final Set<int> colors;

  GuessingSolverIterator(LogicalSolver solver, this.colors) {
    _solvers.add(solver);
  }

  @override
  Solution get current => Solution(_solver.grid, _solver.steps);

  @override
  bool moveNext() {
    if (_solvers.isEmpty) {
      return false;
    }

    while (_solvers.isNotEmpty) {
      _solver = _solvers.removeLast();
      final nonogram = _solver.nonogram;
      final grid = _solver.grid;

      final lSolver = LogicalSolver(nonogram, grid, steps: _solver.steps);
      lSolver.solve();

      if (nonogram.solvedBy(grid)) {
        return true;
      }

      if (grid.filledOut) {
        continue;
      }

      // start guessing
      Position cell = const Position(-1, -1);
      for (var i = 0; i < grid.height; i++) {
        for (var j = 0; j < grid.width; j++) {
          if (grid.get(i, j) != null) {
            continue;
          }
          cell = Position(i, j);
        }
      }

      for (var color in colors) {
        var gridCopy = grid.copy();
        gridCopy.set(cell.row, cell.column, color);
        _solvers.add(LogicalSolver(nonogram, gridCopy,
            steps: [..._solver.steps, Step(cell, color, branch: true)]));
      }
    }

    return false;
  }
}
