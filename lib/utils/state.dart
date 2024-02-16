import 'package:dinar_watch/utils/enums.dart';

class AppState<T> {
  final LoadState state;
  final T? data;
  final String? errorMessage;

  AppState._({required this.state, this.data, this.errorMessage});

  factory AppState.loading() {
    return AppState<T>._(state: LoadState.loading);
  }

  factory AppState.success(T data) {
    return AppState<T>._(state: LoadState.success, data: data);
  }

  factory AppState.error(String message) {
    return AppState<T>._(state: LoadState.error, errorMessage: message);
  }
}
