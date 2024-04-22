// ignore: file_names
// ignore: file_names
import 'package:firebase_core/firebase_core.dart';


class FirebaseErrorInterpreter {
  static ErrorResult interpret(Exception exception) {
    if (exception is FirebaseException) {
      // Check if the error is from firebase_messaging and handle accordingly
      if (exception.plugin == "firebase_messaging" &&
          exception.message!.contains("SERVICE_NOT_AVAILABLE")) {
        // For firebase_messaging related errors that are not critical, allow the app to continue
        return ErrorResult(
          message:
              "Messaging service temporarily unavailable. You can still use the app.",
          code: 503,
          canContinue: true,
        );
      }
      switch (exception.code) {
        case 'permission-denied':
          return ErrorResult(
              message:
                  "There's a problem with the app. Please contact support.",
              code: 403);
        case 'network-request-failed':
          return ErrorResult(
              message: "Please check your internet connection and try again.",
              code: 503);
        // Add more cases as needed
        default:
          return ErrorResult(
              message: "Something went wrong. Please try again later.",
              code: 500);
      }
    } else {
      // Handle non-Firebase exceptions if necessary
      return ErrorResult(
          message: "An unexpected error occurred. Please try again later.",
          code: 500);
    }
  }
}
class ErrorResult {
  final String message;
  final int code;
  final bool canContinue; // Indicates if the app can continue after the error

  ErrorResult({
    required this.message,
    this.code = 500,
    this.canContinue =
        false, // Default to false, indicating the error is critical
  });
}
