// sample_test.dart
import 'package:dart_class_wrapper/dart_class_wrapper.dart';
import 'package:test/test.dart';

import 'sample.dart';

@GenerateWithMethodSetters([Sample])
import 'sample_test.wrapper.dart';

void main() {
  test('Wrap connection', () {
    final obj = WrapperSample();
    obj.mockIsConnected = () => true;
    expect(obj.get(), 10);
    obj.mockIsConnected = () => false;
    expect(obj.get(), null);
  });
}

// sample.dart
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
