import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

@immutable
abstract class BlocStatus<T> extends Equatable {
  const BlocStatus();

  @override
  List<Object?> get props => [];
}

/// initial state
class BlocStatusInitial<T> extends BlocStatus<T> {
  const BlocStatusInitial();

  @override
  List<Object?> get props => [];

  @override
  String toString() => 'BlocStatusInitial';
}

/// loading state
class BlocStatusLoading<T> extends BlocStatus<T> {
  final ValueNotifier<double>? valueLoading;
  const BlocStatusLoading({this.valueLoading});
  @override
  List<Object?> get props => [valueLoading];

  @override
  String toString() => 'BlocStatusLoading';
}

/// loaded state
class BlocStatusCompleted<T> extends BlocStatus<T> {
  final T value;
  const BlocStatusCompleted(this.value);

  @override
  List<Object?> get props => [value];

  BlocStatusCompleted<T> copyWith({T? value}) {
    return BlocStatusCompleted<T>(value ?? this.value);
  }

  @override
  String toString() => 'BlocStatusCompleted(value: $value)';
}

/// error state
class BlocStatusError<T> extends BlocStatus<T> {
  final String? message;

  final int? statusCode;
  final Map<String, String>? formError;
  const BlocStatusError(this.message, this.statusCode, {this.formError});

  @override
  List<Object?> get props => [message, statusCode, formError];

  BlocStatusError<T> copyWith({String? message, int? statusCode}) {
    return BlocStatusError<T>(
      message ?? this.message,
      statusCode ?? this.statusCode,
    );
  }

  @override
  String toString() =>
      'BlocStatusError(message: $message, statusCode: $statusCode, formError: $formError )';
}
