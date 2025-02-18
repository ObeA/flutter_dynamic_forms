import 'package:expression_language/src/expressions/expressions.dart';
import 'package:expression_language/src/grammar/expression_grammar_definition.dart';
import 'package:expression_language/src/number_type/decimal.dart';
import 'package:expression_language/src/number_type/integer.dart';
import 'package:expression_language/src/number_type/number.dart';
import 'package:expression_language/src/parser/function_expression_factories/default_function_expression_factories.dart';
import 'package:expression_language/src/parser/expression_factory.dart';
import 'package:expression_language/src/parser/function_expression_factory.dart';
import 'package:petitparser/petitparser.dart';

class ExpressionGrammarParser extends ExpressionGrammarDefinition {
  final ExpressionProviderElement expressionProviderElementMap;
  final List<FunctionExpressionFactory> customFunctionExpressionFactories;
  final Map<String, FunctionExpressionFactoryMethod> _expressionFactories;

  ExpressionGrammarParser({
    required this.expressionProviderElementMap, // TODO: rename
    this.customFunctionExpressionFactories = const [],
  }) : _expressionFactories =
            _createFunctionExpressionFactoriesMap(customFunctionExpressionFactories);

  static Map<String, FunctionExpressionFactoryMethod> _createFunctionExpressionFactoriesMap(
      List<FunctionExpressionFactory> customFunctionExpressionFactories) {
    var customMap = {
      for (var v in customFunctionExpressionFactories) v.functionName: v.createExpression
    };
    var defaultMap = {
      for (var v in getDefaultFunctionExpressionFactories()) v.functionName: v.createExpression
    };
    return defaultMap..addAll(customMap);
  }

  @override
  Parser additiveExpression() => super.additiveExpression().map((c) {
        Expression left = c[0];
        for (var item in c[1]) {
          Expression right = item[1];
          if (item[0].value == '+') {
            if (left is Expression<Number> && right is Expression<Number>) {
              left = PlusNumberExpression(left, right);
              continue;
            }
            if (left is Expression<String?> && right is Expression<String?>) {
              left = PlusStringExpression(left, right);
              continue;
            }
            if (left is Expression<String> && right is Expression<Number>) {
              left = PlusStringExpression(left, ToStringFunctionExpression(right));
              continue;
            }
            if (left is Expression<Number> && right is Expression<String>) {
              left = PlusStringExpression(ToStringFunctionExpression(left), right);
              continue;
            }
            if (left is Expression<Duration> && right is Expression<DateTime>) {
              left = DateTimePlusDurationExpression(right, left);
              continue;
            }
            if (left is Expression<DateTime> && right is Expression<Duration>) {
              left = DateTimePlusDurationExpression(left, right);
              continue;
            }
            if (left is Expression<Duration> && right is Expression<Duration>) {
              left = PlusDurationExpression(left, right);
              continue;
            }
          }
          if (item[0].value == '-') {
            if ((left is Expression<Number>) && (right is Expression<Number>)) {
              left = MinusNumberExpression(left, right);
              continue;
            }
            if ((left is Expression<DateTime>) && (right is Expression<Duration>)) {
              left = DateTimeMinusDurationExpression(left, right);
              continue;
            }
            if ((left is Expression<Duration>) && (right is Expression<Duration>)) {
              left = MinusDurationExpression(left, right);
              continue;
            }
          }
          throw UnknownExpressionTypeException('Unknown additive expression type');
        }
        return left;
      });

  @override
  Parser multiplicativeExpression() => super.multiplicativeExpression().map((c) {
        Expression left = c[0];
        for (var item in c[1]) {
          Expression right = item[1];
          if ((item[0] is List) && (item[0][0].value == '~') && (item[0][1].value == '/')) {
            left = IntegerDivisionNumberExpression(
                left as Expression<Number>, right as Expression<Number>);
            continue;
          }
          if (item[0].value == '*') {
            if (left is Expression<Number> && right is Expression<Number>) {
              left = MultiplyNumberExpression(left, right);
              continue;
            }
            if (left is Expression<Duration> && right is Expression<Integer>) {
              left = MultiplyDurationExpression(left, right);
              continue;
            }
          }
          if (item[0].value == '/') {
            if (left is Expression<Number> && right is Expression<Number>) {
              left = DivisionNumberExpression(left, right);
              continue;
            }
            if (left is Expression<Duration> && right is Expression<Integer>) {
              left = DivisionDurationExpression(left, right);
              continue;
            }

            continue;
          }
          if (item[0].value == '%') {
            left = ModuloExpression(left as Expression<Number>, right as Expression<Number>);
            continue;
          }
          throw UnknownExpressionTypeException('Unknown multiplicative expression type');
        }
        return left;
      });

  @override
  Parser expressionInParentheses() => super.expressionInParentheses().map((c) => c[1]);

  @override
  Parser unaryExpression() => super.unaryExpression().map((c) {
        if (c is List && c.length == 2) {
          if (c[0].value == '-') {
            if (c[1] is Expression<Number>) {
              return NegateNumberExpression(c[1]);
            }
            if (c[1] is Expression<Duration>) {
              return NegateDurationExpression(c[1]);
            }
          } else if (c[0].value == '!') {
            if (c[1] is Expression<bool>) {
              return NegateBoolExpression(c[1]);
            }
          }
        }
        return c;
      });

  @override
  Parser postfixOperatorExpression() => super.postfixOperatorExpression().map((c) {
        if (c[1] == null) {
          return c[0];
        }
        return createNonNullableConversionExpression(c[0]);
      });

  @override
  Parser conditionalExpression() => super.conditionalExpression().map((c) {
        if (c[1] == null) {
          return c[0];
        }
        return createConditionalExpression(c[0], c[1][1], c[1][3]);
      });

  @override
  Parser logicalOrExpression() => super.logicalOrExpression().map((c) {
        Expression expression = c[0];
        for (var item in c[1]) {
          if (item[0].value == '||') {
            expression = LogicalOrExpression(expression as Expression<bool>, item[1]);
            continue;
          }
          throw UnknownExpressionTypeException('Unknown logical-or expression type');
        }
        return expression;
      });

  @override
  Parser logicalAndExpression() => super.logicalAndExpression().map((c) {
        Expression expression = c[0];
        for (var item in c[1]) {
          if (item[0].value == '&&') {
            expression = LogicalAndExpression(expression as Expression<bool>, item[1]);
            continue;
          }
          throw UnknownExpressionTypeException('Unknown logical-and expression type');
        }
        return expression;
      });

  @override
  Parser equalityExpression() => super.equalityExpression().map((c) {
        Expression left = c[0];
        if (c[1] == null) {
          return left;
        }
        var item = c[1];
        var right = item[1];
        if (item[0].value == '==') {
          if ((left is Expression<Number>) && (right is Expression<Number>)) {
            left = EqualNumberExpression(left, right);
          } else if ((left is Expression<bool>) && (right is Expression<bool>)) {
            left = EqualBoolExpression(left, right);
          } else if ((left is Expression<String>) && (right is Expression<String>)) {
            left = EqualStringExpression(left, right);
          } else if ((left is Expression<DateTime>) && (right is Expression<DateTime>)) {
            left = EqualDateTimeExpression(left, right);
          } else if ((left is Expression<Duration>) && (right is Expression<Duration>)) {
            left = EqualDurationExpression(left, right);
          }
        } else if (item[0].value == '!=') {
          if ((left is Expression<Number>) && (right is Expression<Number>)) {
            left = NegateBoolExpression(EqualNumberExpression(left, right));
          } else if ((left is Expression<bool>) && (right is Expression<bool>)) {
            left = NegateBoolExpression(EqualBoolExpression(left, right));
          } else if ((left is Expression<String>) && (right is Expression<String>)) {
            left = NegateBoolExpression(EqualStringExpression(left, right));
          } else if ((left is Expression<DateTime>) && (right is Expression<DateTime>)) {
            left = NegateBoolExpression(EqualDateTimeExpression(left, right));
          } else if ((left is Expression<Duration>) && (right is Expression<Duration>)) {
            left = NegateBoolExpression(EqualDurationExpression(left, right));
          } else {
            throw UnknownExpressionTypeException('Unknown equality expression type');
          }
        }
        return left;
      });

  @override
  Parser relationalExpression() => super.relationalExpression().map((c) {
        Expression left = c[0];
        if (c[1] == null) {
          return left;
        }
        var item = c[1];
        var right = item[1];
        if (item[0].value == '<') {
          if ((left is Expression<Number>) && (right is Expression<Number>)) {
            left = LessThanNumberExpression(left, right);
          } else if ((left is Expression<DateTime>) && (right is Expression<DateTime>)) {
            left = LessThanDateTimeExpression(left, right);
          } else if ((left is Expression<Duration>) && (right is Expression<Duration>)) {
            left = LessThanDurationExpression(left, right);
          }
        } else if (item[0].value == '<=') {
          if ((left is Expression<Number>) && (right is Expression<Number>)) {
            left = LessThanOrEqualNumberExpression(left, right);
          } else if ((left is Expression<DateTime>) && (right is Expression<DateTime>)) {
            left = LessThanOrEqualDateTimeExpression(left, right);
          } else if ((left is Expression<Duration>) && (right is Expression<Duration>)) {
            left = LessThanOrEqualDurationExpression(left, right);
          }
        } else if (item[0].value == '>') {
          if ((left is Expression<Number>) && (right is Expression<Number>)) {
            left = LessThanNumberExpression(right, left);
          } else if ((left is Expression<DateTime>) && (right is Expression<DateTime>)) {
            left = LessThanDateTimeExpression(right, left);
          } else if ((left is Expression<Duration>) && (right is Expression<Duration>)) {
            left = LessThanDurationExpression(right, left);
          }
        } else if (item[0].value == '>=') {
          if ((left is Expression<Number>) && (right is Expression<Number>)) {
            left = LessThanOrEqualNumberExpression(right, left);
          } else if ((left is Expression<DateTime>) && (right is Expression<DateTime>)) {
            left = LessThanOrEqualDateTimeExpression(right, left);
          } else if ((left is Expression<Duration>) && (right is Expression<Duration>)) {
            left = LessThanOrEqualDurationExpression(right, left);
          }
        } else {
          throw UnknownExpressionTypeException('Unknown relational expression type');
        }
        return left;
      });

  @override
  Parser reference() => super.reference().map((c) {
        // var expressionPath = <String>[];
        // const base = 0;
        // String elementId = c[base];
        // expressionPath.add(elementId);
        if (c is! String) {
          throw UnknownExpressionTypeException('Reference must be a string');
        }

        final parts = c.split('.');
        final expressionProvider = expressionProviderElementMap.getExpressionProvider(c);
        // if (expressionProviderElement == null) {
        //   throw NullReferenceException(
        //       'Reference named {$elementId} does not exist.');
        // }
        // ExpressionProvider? expressionProvider;
        // if (c[base + 1].length == 0) {
        //   expressionProvider =
        //       expressionProviderElement.getExpressionProvider();
        //   return createDelegateExpression(expressionPath, expressionProvider);
        // }
        // for (var i = 0; i < c[base + 1].length; i++) {
        //   var propertyName = c[base + 1][i][1];
        //   expressionPath.add(propertyName);
        //   expressionProvider =
        //       expressionProviderElement!.getExpressionProvider(propertyName);
        //   if (expressionProvider
        //       is ExpressionProvider<ExpressionProviderElement>) {
        //     expressionProviderElement =
        //         expressionProvider.getExpression().evaluate();
        //   }
        // }
        return createDelegateExpression(parts, expressionProvider);
      });

  @override
  Parser integerNumber() =>
      super.integerNumber().flatten().map((c) => ConstantExpression<Integer>(Integer.parse(c)));

  @override
  Parser decimalNumber() =>
      super.decimalNumber().flatten().map((c) => ConstantExpression<Decimal>(Decimal.parse(c)));

  @override
  Parser singleLineString() => super
      .singleLineString()
      .flatten()
      .map((c) => ConstantExpression<String>(c.substring(1, c.length - 1)));

  @override
  Parser functionParameters() => super.functionParameters().map((c) {
        var result = <Expression>[];
        for (var i = 0; i < c[0].length; i++) {
          result.add(c[0][i][0]);
        }
        result.add(c[1]);
        return result;
      });

  @override
  Parser literal() => super.literal().map((c) => c.value);

  @override
  Parser function() => super
      .function()
      .map((c) => createFunctionExpression(c[0], c[2] ?? <Expression>[], _expressionFactories));

  @override
  Parser TRUE() => super.TRUE().map((c) => ConstantExpression<bool>(c.value == 'true'));

  @override
  Parser FALSE() => super.FALSE().map((c) => ConstantExpression<bool>(c.value != 'false'));
}
