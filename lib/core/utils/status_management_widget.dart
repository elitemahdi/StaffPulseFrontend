
import 'package:flutter/material.dart';
import 'package:staffpulseapp/core/utils/bloc_states.dart';

class StatusManageWidget<T> extends StatelessWidget {
  final BlocStatus<T> status;
  final Widget Function()? initialWidget;
  final Widget Function() loadingWidget;
  final Widget Function(String? message, int? statusCode) errorWidgetBuilder;
  final Widget Function(T value) completedWidgetBuilder;
  final bool shouldCheckAccess;

  const StatusManageWidget({
    super.key,
    required this.status,
    this.initialWidget,
    required this.loadingWidget,
    required this.errorWidgetBuilder,
    required this.completedWidgetBuilder,
    this.shouldCheckAccess = true,
  });

  @override
  Widget build(BuildContext context) {
    if (status is BlocStatusInitial<T>) {
      if (initialWidget != null) {
        return initialWidget!();
      }
      return loadingWidget();
    } else if (status is BlocStatusLoading<T>) {
      return loadingWidget();
    } else if (status is BlocStatusCompleted<T>) {
      final value = (status as BlocStatusCompleted<T>).value;
      return completedWidgetBuilder(value);
    } else if (status is BlocStatusError<T>) {
      final error = status as BlocStatusError<T>;
      if (shouldCheckAccess && error.statusCode == 403) {
        return const SizedBox();
      } else {
        return errorWidgetBuilder(error.message, error.statusCode);
      }
    } else {
      return Container();
    }
  }
}
