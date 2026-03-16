import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

abstract class ThemeState extends Equatable {
  final ThemeData themeData;
  const ThemeState(this.themeData);

  @override
  List<Object?> get props => [themeData];
}

class LightThemeState extends ThemeState {
  LightThemeState() : super(
    ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue, brightness: Brightness.light),
      useMaterial3: true,
    ),
  );
}

class DarkThemeState extends ThemeState {
  DarkThemeState() : super(
    ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue, brightness: Brightness.dark),
      useMaterial3: true,
    ),
  );
}