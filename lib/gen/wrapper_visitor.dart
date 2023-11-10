// Copyright 2023 The terCAD team. All rights reserved.
// Use of this source code is governed by a MIT license
// that can be found in the LICENSE file.

import 'package:analyzer/dart/element/element.dart';

// Parse classes from @GenerateWithMethodSetters notation
class WrapperVisitor {
  // Output buffer for the class
  StringBuffer buffer = StringBuffer();
  // Element interface
  InterfaceElement element;
  // Check if Singleton pattern was used
  String? singleton;

  // Run visitor for the targeted element
  WrapperVisitor(this.element);

  // Bind all imports
  static List<String> getImports(InterfaceElement element) {
    final mainClass = element.enclosingElement.library;
    List<String> result = [_getImport(mainClass)];
    for (final cls in mainClass.importedLibraries) {
      result.add(_getImport(cls));
    }
    return result;
  }

  static String _getImport(LibraryElement className) {
    String path = className.source.uri.toString();
    if (path.contains('asset:')) {
      path = className.source.uri.pathSegments.last;
    }
    String ignore = '// ignore: unused_import, unnecessary_import, '
        'depend_on_referenced_packages\n';
    return "${ignore}import '$path';";
  }

  void _withMixin() {
    buffer.writeln('class Wrapper${element.name} with ${element.name} {');
  }

  void _withPrivateConstructor() {
    buffer.writeln('class Wrapper${element.name} implements ${element.name} {');
    buffer.writeln('  static ${element.name}? wrap${element.name};');
    singleton = element.name;
  }

  void _withConstructor() {
    buffer.writeln('class Wrapper${element.name} extends ${element.name} {');
    final constructor = element.unnamedConstructor;
    final properties = constructor?.parameters ?? [];
    if (properties.isNotEmpty) {
      buffer.writeln('  Wrapper${element.name}(');
      if (properties.isNotEmpty) {
        buffer.writeln(_getTypedArguments(properties, 'super.'));
      }
      buffer.writeln('  );');
    }
  }

  // Identify the class definition
  void addClassDefinition() {
    if (element is MixinElement) {
      _withMixin();
    } else if (element.unnamedConstructor == null) {
      _withPrivateConstructor();
    } else {
      _withConstructor();
    }
  }

  String _getTypedArguments(List<ParameterElement> parameters,
      [String? prefix]) {
    List<String> optional = [];
    List<String> named = [];
    List<String> base = [];
    for (ParameterElement e in parameters) {
      String arg = prefix != null ? '$prefix${e.name}' : '${e.type} ${e.name}';
      if (e.isNamed) {
        named.add('${e.isRequired ? 'required ' : ''}$arg');
      } else if (e.isOptional) {
        optional.add(arg);
      } else {
        base.add(arg);
      }
    }
    if (named.isNotEmpty) {
      base.add('{${named.join(', ')}}');
    }
    if (optional.isNotEmpty) {
      base.add('[${optional.join(', ')}]');
    }
    return base.join(', ');
  }

  String _getName(dynamic element) {
    return 'mock${element.name[0].toUpperCase()}${element.name.substring(1)}';
  }

  // Generate getters
  void addGetters() {
    for (PropertyAccessorElement m in element.accessors) {
      if (m.name[0] == '_' || !m.isGetter) {
        continue;
      }
      buffer.writeln('');
      final static = m.isStatic ? 'static ' : '';
      final conditional = m.returnType.toString().contains('?') ? '' : '?';
      buffer.writeln('  $static${m.returnType}$conditional _${m.name};');
      buffer.writeln('  // ignore: non_constant_identifier_names');
      buffer.writeln('  ${static}set ${_getName(m)}(${m.returnType} value) {');
      buffer.writeln('    _${m.name} = value;');
      buffer.writeln('  }');
      if (singleton == null && !m.isStatic) {
        buffer.writeln('  @override');
        buffer.writeln('  // ignore: unnecessary_overrides');
      }
      final parent = m.isStatic ? element.name : 'super';
      buffer.writeln('  $static$m => _${m.name} ?? $parent.${m.name};');
      buffer.writeln('');
    }
  }

  // Generate setters
  void addMethods() {
    for (MethodElement m in element.methods) {
      if (m.name[0] == '_') {
        continue;
      }
      final args = m.parameters
          .map((e) => e.isNamed ? '${e.name}: ${e.name}' : e.name)
          .toList()
          .join(', ');
      final typedArgs = _getTypedArguments(m.parameters);
      String static = m.isStatic ? 'static ' : '';
      final name = _getName(m);
      buffer.writeln('');
      buffer.writeln(
          '  $static${m.returnType} Function($typedArgs)? _${m.name};');
      buffer.writeln('  // ignore: non_constant_identifier_names');
      buffer.writeln(
          '  ${static}set $name(${m.returnType} Function($typedArgs) value) {');
      buffer.writeln('    _${m.name} = value;');
      buffer.writeln('  }');
      buffer.writeln('');
      if (singleton != null) {
        final stat = m.isStatic ? singleton : 'wrap$singleton!';
        buffer.writeln('  $static$m => _${m.name} != null ? '
            '_${m.name}!($args) : $stat.${m.name}($args);');
      } else {
        if (!m.isStatic) {
          buffer.writeln('  @override');
        }
        final parent = m.isStatic ? element.name : 'super';
        buffer.writeln(
            '  $static$m => (_${m.name} ?? $parent.${m.name})($args);');
      }
    }
  }

  // Finalize the class definition
  void finalize() {
    buffer.writeln('}');
  }

  @override
  // Flash taken results
  String toString() {
    addClassDefinition();
    addGetters();
    addMethods();
    finalize();
    return buffer.toString();
  }
}
