// ignore_for_file: constant_identifier_names

library ventx;

import 'package:flutter/material.dart';

enum States {
  LOADING,
  EMPTY,
  ERROR,
  SUCCESS;

  bool get isLoading => this == States.LOADING;
  bool get isEmpty => this == States.EMPTY;
  bool get isError => this == States.ERROR;
  bool get isSuccess => this == States.SUCCESS;
}

class StatesData {
  final States state;
  final String? message;

  StatesData._({
    this.state = States.LOADING,
    this.message,
  });

  factory StatesData.loading() {
    return StatesData._(state: States.LOADING);
  }

  factory StatesData.success() {
    return StatesData._(state: States.SUCCESS);
  }

  factory StatesData.error(String? message) {
    return StatesData._(state: States.ERROR, message: message);
  }

  factory StatesData.empty([String? message]) {
    return StatesData._(state: States.EMPTY, message: message);
  }
}

class Vx<T> {
  final ValueNotifier<StatesData?> _stateNotifier = ValueNotifier<StatesData?>(null);
  final ValueNotifier<T?> _dataNotifier = ValueNotifier<T?>(null);

  Vx({T? data, StatesData? status}) {
    update(data, status: status ?? StatesData.loading());
  }
  void update(T? data, {StatesData? status}) {
    _dataNotifier.value = data;
    _stateNotifier.value = status;
  }

  StatesData get status => _stateNotifier.value ?? StatesData.loading();
  T? get value => _dataNotifier.value;
  ValueNotifier<StatesData?> get statusListener => _stateNotifier;
  ValueNotifier<T?> get dataListener => _dataNotifier;

  Widget builder({
    required Widget Function(T? data) onSuccess,
    Widget Function(String? message)? onEmpty,
    Widget Function(String? message)? onError,
    Widget? onLoading,
  }) {
    return ValueListenableBuilder<T?>(
      valueListenable: dataListener,
      builder: (_, dataValue, ___) {
        return ValueListenableBuilder<StatesData?>(
          valueListenable: statusListener,
          builder: (context, stateValue, child) {
            var loading = onLoading ?? const Center(child: CircularProgressIndicator());
            var empty = onEmpty != null
                ? onEmpty(status.message)
                : Center(child: Text(status.message ?? "EMPTY"));
            var error = onError != null
                ? onError(status.message)
                : Center(child: Text(status.message ?? "ERROR"));
            return switch (stateValue?.state) {
              States.LOADING => loading,
              States.EMPTY => empty,
              States.ERROR => error,
              _ => onSuccess(dataValue),
            };
          },
        );
      },
    );
  }
}
