// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// WrapperGenerator
// **************************************************************************

// ignore: unused_import, unnecessary_import, depend_on_referenced_packages
import 'sample.dart';
// ignore: unused_import, unnecessary_import, depend_on_referenced_packages
import 'dart:core';

class WrapperSample extends Sample {
  bool Function()? _isConnected;
  // ignore: non_constant_identifier_names
  set mockIsConnected(bool Function() value) {
    _isConnected = value;
  }

  @override
  bool isConnected() => (_isConnected ?? super.isConnected)();

  double? Function()? _get;
  // ignore: non_constant_identifier_names
  set mockGet(double? Function() value) {
    _get = value;
  }

  @override
  double? get() => (_get ?? super.get)();
}
