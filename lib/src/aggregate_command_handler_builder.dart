import 'dart:async';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/visitor.dart';
import 'package:build/build.dart';
import 'package:dart_event_sourcing/commandhandling.dart';
import 'package:source_gen/source_gen.dart';

import 'package:dart_event_sourcing/modeling.dart';

Builder aggregateCommandHandler(BuilderOptions options) =>
    LibraryBuilder(
      AggregateCommandHandlerGenerator(),
      generatedExtension: ".command_handler.dart"
    );

class AggregateCommandHandlerGenerator
    extends GeneratorForAnnotation<Aggregate> {

  @override
  FutureOr<String> generateForAnnotatedElement(
      Element element, ConstantReader annotation, BuildStep buildStep) {

    return _Generator(element).generate();
  }
}

class _Generator extends SimpleElementVisitor {

  final ClassElement classElement;
  _Generator(
    this.classElement
  );

  final commandHandlerChecker = TypeChecker.fromRuntime(CommandHandler);

  String get aggregateClassName => classElement.displayName;
  String get aggregateName => classElement.displayName.toLowerCase();
  String get handlerClassName => "${aggregateClassName}CommandHandler";


  List<MethodElement> get commandHandlers => classElement.methods.where((m) =>
      commandHandlerChecker.hasAnnotationOfExact(m)
  );

  String generate() {
    classElement.visitChildren(this);
    return """
    |import './${aggregateName}.dart';
    |
    |/// A handler class for ${aggregateName} aggregates.
    |class ${handlerClassName} {
    |  ${aggregateClassName} aggregate;
    |  ${handlerClassName}(this.aggregate);
    |}
    |""".replaceAll(RegExp(r'(^|\n)\s*\|'), '\n').trim();
  }
}
//https://stackoverflow.com/questions/58683646/how-to-generate-dart-code-for-annotations-at-fields
//https://stackoverflow.com/questions/57703473/how-to-read-the-annotation-fields-and-their-values-code-generation

class _CommandHandlerInfo {
  String commandType;
  String handlerMethodName;
}

