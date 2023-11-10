class Sample {
  Sample();

  bool isConnected() {
    throw Exception('Emulate connection');
  }

  double? get() {
    if (isConnected()) {
      return 10;
    }
    return null;
  }
}
