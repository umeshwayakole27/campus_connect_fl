import 'package:flutter/material.dart';
import '../constants.dart';
import '../utils.dart';

enum ErrorType {
  network,
  server,
  auth,
  permission,
  validation,
  unknown,
}

class AppError {
  final String message;
  final ErrorType type;
  final dynamic originalError;
  final StackTrace? stackTrace;

  AppError({
    required this.message,
    required this.type,
    this.originalError,
    this.stackTrace,
  });

  @override
  String toString() => message;
}

class ErrorService {
  static ErrorService? _instance;
  static ErrorService get instance => _instance ??= ErrorService._();

  ErrorService._();

  AppError handleError(dynamic error, {StackTrace? stackTrace}) {
    AppLogger.logError('Error occurred', error: error, stackTrace: stackTrace);

    if (error is AppError) {
      return error;
    }

    String message = AppConstants.errorGeneric;
    ErrorType type = ErrorType.unknown;

    if (error is Exception) {
      final errorString = error.toString().toLowerCase();
      
      if (errorString.contains('network') || 
          errorString.contains('socket') ||
          errorString.contains('connection')) {
        message = AppConstants.errorNetwork;
        type = ErrorType.network;
      } else if (errorString.contains('auth') || 
                 errorString.contains('unauthorized') ||
                 errorString.contains('token')) {
        message = AppConstants.errorAuth;
        type = ErrorType.auth;
      } else if (errorString.contains('permission') || 
                 errorString.contains('forbidden')) {
        message = AppConstants.errorPermission;
        type = ErrorType.permission;
      } else if (errorString.contains('server') || 
                 errorString.contains('500')) {
        message = AppConstants.errorServer;
        type = ErrorType.server;
      }
    }

    return AppError(
      message: message,
      type: type,
      originalError: error,
      stackTrace: stackTrace,
    );
  }

  void showError(BuildContext context, dynamic error) {
    final appError = error is AppError ? error : handleError(error);
    AppUtils.showSnackBar(context, appError.message, isError: true);
  }

  AppError createError(String message, ErrorType type) {
    return AppError(message: message, type: type);
  }

  AppError networkError([String? customMessage]) {
    return AppError(
      message: customMessage ?? AppConstants.errorNetwork,
      type: ErrorType.network,
    );
  }

  AppError authError([String? customMessage]) {
    return AppError(
      message: customMessage ?? AppConstants.errorAuth,
      type: ErrorType.auth,
    );
  }

  AppError permissionError([String? customMessage]) {
    return AppError(
      message: customMessage ?? AppConstants.errorPermission,
      type: ErrorType.permission,
    );
  }

  AppError validationError(String message) {
    return AppError(
      message: message,
      type: ErrorType.validation,
    );
  }
}
