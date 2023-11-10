// Copyright 2023 The terCAD team. All rights reserved.
// Use of this source code is governed by a MIT license
// that can be found in the LICENSE file.

import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/constant/value.dart';
import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';

import 'generate_with_method_setters.dart';
import 'wrapper_visitor.dart';

// Library builder with preset for '*.wrapper.dart' files
Builder wrapperGenerator(BuilderOptions options) => LibraryBuilder(
      WrapperGenerator(),
      generatedExtension: '.wrapper.dart',
    );

// Wrapper class generator
class WrapperGenerator extends Generator {
  // Generate wrapped class from @GenerateWithMethodSetters notation
  String build(Iterable<DartObject> annotations) {
    final result = StringBuffer();
    for (final annotation in annotations) {
      final classes = annotation.getField('classes');
      if (classes == null || classes.isNull) {
        continue;
      }
      Set<String> imports = {};
      for (final name in classes.toListValue()!) {
        imports.addAll(WrapperVisitor.getImports(
            name.toTypeValue()?.element as InterfaceElement));
      }
      result.writeln(imports.toList().join('\n'));
      result.writeln('');
      for (final name in classes.toListValue()!) {
        final type = name.toTypeValue();
        final classElement = type?.element as InterfaceElement;
        final visitor = WrapperVisitor(classElement);
        result.writeln(visitor.toString());
      }
    }
    return result.toString();
  }

  @override
  // Return results for the whole scope of notations
  String generate(LibraryReader library, BuildStep buildStep) {
    final result = StringBuffer();
    for (final element in library.allElements) {
      final annotations =
          const TypeChecker.fromRuntime(GenerateWithMethodSetters)
              .annotationsOf(element);
      if (annotations.isNotEmpty) {
        result.writeln(build(annotations));
      }
    }
    return result.toString();
  }
}
