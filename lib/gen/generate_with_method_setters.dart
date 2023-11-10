// Copyright 2023 The terCAD team. All rights reserved.
// Use of this source code is governed by a MIT license
// that can be found in the LICENSE file.

// Generate wrappers of classes with a setter for each method to override flow
class GenerateWithMethodSetters {
  // List of classes to generate their wrappers
  final List<Type> classes;
  // Create wrappers
  const GenerateWithMethodSetters([this.classes = const []]);
}
