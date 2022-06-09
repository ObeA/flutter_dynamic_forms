import 'package:expression_language/expression_language.dart';

import 'round_function_expression_factory.dart';

List<FunctionExpressionFactory> getDefaultFunctionExpressionFactories() {
  return [
    RoundFunctionExpressionFactory(),
    ExplicitFunctionExpressionFactory(
      name: 'LENGTH',
      parametersLength: 1,
      createFunctionExpression: (parameters) =>
          LengthFunctionExpression(parameters[0] as Expression<String>),
    ),
    ExplicitFunctionExpressionFactory(
      name: 'TO_STRING',
      parametersLength: 1,
      createFunctionExpression: (parameters) =>
          ToStringFunctionExpression(parameters[0]),
    ),
    ExplicitFunctionExpressionFactory(
      name: 'IS_NULL',
      parametersLength: 1,
      createFunctionExpression: (parameters) =>
          IsNullFunctionExpression(parameters[0]),
    ),
    ExplicitFunctionExpressionFactory(
      name: 'IS_EMPTY',
      parametersLength: 1,
      createFunctionExpression: (parameters) =>
          IsEmptyFunctionExpression(parameters[0] as Expression<String>),
    ),
    ExplicitFunctionExpressionFactory(
      name: 'IS_NULL_OR_EMPTY',
      parametersLength: 1,
      createFunctionExpression: (parameters) =>
          IsNullOrEmptyFunctionExpression(parameters[0] as Expression<String?>),
    ),
    ExplicitFunctionExpressionFactory(
      name: 'COUNT',
      parametersLength: 1,
      createFunctionExpression: (parameters) => ListCountFunctionExpression(
          parameters[0] as Expression<List<dynamic>>),
    ),
    ExplicitFunctionExpressionFactory(
      name: 'DATE_TIME',
      parametersLength: 1,
      createFunctionExpression: (parameters) =>
          DateTimeFunctionExpression(parameters[0] as Expression<String>),
    ),
    ExplicitFunctionExpressionFactory(
      name: 'DURATION',
      parametersLength: 1,
      createFunctionExpression: (parameters) =>
          DurationFunctionExpression(parameters[0] as Expression<String>),
    ),
    ExplicitFunctionExpressionFactory(
      name: 'NOW',
      parametersLength: 0,
      createFunctionExpression: (parameters) => NowFunctionExpression(),
    ),
    ExplicitFunctionExpressionFactory(
      name: 'NOW_IN_UTC',
      parametersLength: 0,
      createFunctionExpression: (parameters) => NowInUtcFunctionExpression(),
    ),
    ExplicitFunctionExpressionFactory(
      name: 'DIFF_DATE_TIME',
      parametersLength: 2,
      createFunctionExpression: (parameters) => DiffDateTimeFunctionExpression(
          parameters[0] as Expression<DateTime>,
          parameters[1] as Expression<DateTime>),
    ),
    ExplicitFunctionExpressionFactory(
      name: 'DURATION_IN_DAYS',
      parametersLength: 1,
      createFunctionExpression: (parameters) =>
          DurationInDaysFunctionExpression(
              parameters[0] as Expression<Duration>),
    ),
    ExplicitFunctionExpressionFactory(
      name: 'DURATION_IN_HOURS',
      parametersLength: 1,
      createFunctionExpression: (parameters) =>
          DurationInHoursFunctionExpression(
              parameters[0] as Expression<Duration>),
    ),
    ExplicitFunctionExpressionFactory(
      name: 'DURATION_IN_MINUTES',
      parametersLength: 1,
      createFunctionExpression: (parameters) =>
          DurationInMinutesFunctionExpression(
              parameters[0] as Expression<Duration>),
    ),
    ExplicitFunctionExpressionFactory(
      name: 'DURATION_IN_SECONDS',
      parametersLength: 1,
      createFunctionExpression: (parameters) =>
          DurationInSecondsFunctionExpression(
              parameters[0] as Expression<Duration>),
    ),
    ExplicitFunctionExpressionFactory(
      name: 'MATCHES',
      parametersLength: 2,
      createFunctionExpression: (parameters) => MatchesFunctionExpression(
          parameters[0] as Expression<String>,
          parameters[1] as Expression<String>),
    ),
    ExplicitFunctionExpressionFactory(
      name: 'CONTAINS',
      parametersLength: 2,
      createFunctionExpression: (parameters) => ContainsFunctionExpression(
        parameters[0] as Expression<String?>,
        parameters[1] as Expression<String>,
      ),
    ),
    ExplicitFunctionExpressionFactory(
      name: 'STARTS_WITH',
      parametersLength: 2,
      createFunctionExpression: (parameters) => StartsWithFunctionExpression(
        parameters[0] as Expression<String?>,
        parameters[1] as Expression<String>,
      ),
    ),
    ExplicitFunctionExpressionFactory(
      name: 'ENDS_WITH',
      parametersLength: 2,
      createFunctionExpression: (parameters) => EndsWithFunctionExpression(
        parameters[0] as Expression<String?>,
        parameters[1] as Expression<String>,
      ),
    ),
  ];
}
