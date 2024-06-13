class DataFetchFailureException implements Exception {
  final String message;
  final bool canContinue;

  DataFetchFailureException(this.message, {this.canContinue = false});

  @override
  String toString() => "DataFetchFailureException: $message";
}
