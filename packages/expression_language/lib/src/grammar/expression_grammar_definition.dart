import 'package:petitparser/petitparser.dart';

class ExpressionGrammarDefinition extends GrammarDefinition {
  @override
  Parser start() => (ref0(expression).end()).or(ref0(failureState));

  Parser FALSE() => ref1(token, 'false');
  Parser TRUE() => ref1(token, 'true');
  Parser LETTER() => letter();
  Parser DIGIT() => digit();
  Parser failureState() =>
      (ref0(expression).trim() & ref0(fail).trim()) | ref0(fail).trim();
  Parser fail() => any();
  Parser letterOrSpecialChar() => ref0(LETTER) | ref1(token, '_');

  Parser decimalNumber() =>
      ref0(DIGIT) &
      ref0(DIGIT).star() &
      char('.') &
      ref0(DIGIT) &
      ref0(DIGIT).star();
  Parser integerNumber() => ref0(DIGIT) & ref0(DIGIT).star();
  Parser singleLineString() =>
      char('"') & ref0(stringContent).star() & char('"');
  Parser stringContent() => pattern('^"');
  Parser literal() => ref1(
      token,
      ref0(decimalNumber) |
          ref0(integerNumber) |
          ref0(TRUE) |
          ref0(FALSE) |
          ref0(singleLineString));
  Parser identifier() =>
      ref0(letterOrSpecialChar) &
      (ref0(letterOrSpecialChar) | ref0(DIGIT)).star();

  Parser function() =>
      ref0(identifier).flatten() &
      ref1(token, '(') &
      ref0(functionParameters).optional() &
      ref1(token, ')');
  Parser functionParameters() =>
      (ref0(expression) & ref1(token, ',')).star() & ref0(expression);

  Parser additiveOperator() => ref1(token, '+') | ref1(token, '-');
  Parser relationalOperator() =>
      ref1(token, '>=') |
      ref1(token, '>') |
      ref1(token, '<=') |
      ref1(token, '<');

  Parser equalityOperator() => ref1(token, '==') | ref1(token, '!=');
  Parser multiplicativeOperator() =>
      ref1(token, '*') |
      ref1(token, '/') |
      ref1(token, '~') & ref1(token, '/') |
      ref1(token, '%');

  Parser unaryNegateOperator() => ref1(token, '-') | ref1(token, '!');

  Parser expressionInParentheses() =>
      ref1(token, '(') & ref0(expression) & ref1(token, ')');

  Parser expression() => ref0(conditionalExpression);

  Parser conditionalExpression() =>
      ref0(logicalOrExpression) &
      (ref1(token, '?') &
              ref0(expression) &
              ref1(token, ':') &
              ref0(expression))
          .optional();

  Parser logicalOrExpression() =>
      ref0(logicalAndExpression) &
      (ref1(token, '||') & ref0(logicalAndExpression)).star();

  Parser logicalAndExpression() =>
      ref0(equalityExpression) &
      (ref1(token, '&&') & ref0(equalityExpression)).star();

  Parser equalityExpression() =>
      ref0(relationalExpression) &
      (ref0(equalityOperator) & ref0(relationalExpression)).optional();

  Parser relationalExpression() =>
      ref0(additiveExpression) &
      (ref0(relationalOperator) & ref0(additiveExpression)).optional();

  Parser additiveExpression() =>
      ref0(multiplicativeExpression) &
      (ref0(additiveOperator) & ref0(multiplicativeExpression)).star();

  Parser multiplicativeExpression() =>
      ref0(postfixOperatorExpression) &
      (ref0(multiplicativeOperator) & ref0(postfixOperatorExpression)).star();

  Parser postfixOperatorExpression() =>
      ref0(unaryExpression) & (char('!').seq(char('=').not())).optional();

  Parser unaryExpression() =>
      ref0(literal) |
      ref0(expressionInParentheses) |
      ref0(function) |
      ref0(reference) |
      ref0(unaryNegateOperator) & ref0(unaryExpression);

  Parser reference() => (ref0(identifier).flatten() &
          (char('.') & ref0(identifier).flatten()).star())
      .flatten();

  Parser token(Object input) {
    if (input is Parser) {
      return input.token().trim();
    } else if (input is String) {
      return token(input.length == 1 ? char(input) : string(input));
    } else if (input is Parser<dynamic> Function()) {
      return token(ref0(input));
    }

    throw ArgumentError.value(input, 'invalid token parser');
  }
}
