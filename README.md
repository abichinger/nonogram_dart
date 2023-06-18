<!--
This README describes the package. If you publish this package to pub.dev,
this README's contents appear on the landing page for your package.

For information about how to write a good package README, see the guide for
[writing package pages](https://dart.dev/guides/libraries/writing-package-pages).

For general information about developing packages, see the Dart guide for
[creating packages](https://dart.dev/guides/libraries/create-library-packages)
and the Flutter guide for
[developing packages and plugins](https://flutter.dev/developing-packages).
-->

A nonogram solver written in Dart.

You can see the library in action at [nonobattle.com](https://www.nonobattle.com) | [Google Play](https://play.google.com/store/apps/details?id=com.nonobattle&referrer=utm_source%3Dpub.dev%26utm_medium%3Dpackage)

## Features

- solve nonograms
- generate nonograms
- check if a nonogram is line solveable
- solve nonogram step by step

TODO:

- improve generator
- improve performance of solver

## Usage

### generate a 5x5 nonogram

```dart
final nonogram = Generator.monochrome(5, 5);
```

### solve nonogram

```dart
final nonogram = Generator.monochrome(5, 5);
final solver = GuessingSolver.empty(nonogram);
final solutions = solver.toList();
```

### check if nonogram is line solveable

> no guessing or backtracking is required

```dart
final isLineSolveable = nonogram.isLineSolveable();
```

## Additional information

Nonograms are also know as Hanjie, Paint by Numbers, Picross, Griddlers, and Pic-a-Pix.
