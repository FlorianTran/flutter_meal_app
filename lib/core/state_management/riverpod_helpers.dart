import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Base class for all Riverpod Notifiers
abstract class BaseNotifier<T> extends StateNotifier<T> {
  BaseNotifier(T state) : super(state);

  /// Helper method to update state
  void updateState(T newState) {
    state = newState;
  }
}

/// Async Notifier base class
abstract class BaseAsyncNotifier<T> extends AsyncNotifier<T> {
  @override
  Future<T> build();
}
