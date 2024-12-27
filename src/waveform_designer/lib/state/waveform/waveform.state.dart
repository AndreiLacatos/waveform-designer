import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:waveform_designer/state/waveform/waveform.model.dart';

part 'waveform.state.g.dart';

@riverpod
class WaveFormState extends _$WaveFormState {
  static WaveFormModel _initialState = WaveFormModel(
    duration: 0,
    tickFrequency: 0,
    values: [],
  );

  @override
  WaveFormModel build() {
    return _initialState;
  }

  void initialize(WaveFormModel model) {
    state = model;
  }

  void updateDuration(int newDuration) {
    if (newDuration < state.tickFrequency) {
      throw 'Durationg must be greater than tick frequency!';
    }
    var lastTransition = state.values.lastOrNull?.tick ?? 0;
    if (newDuration < lastTransition) {
      throw 'Duration is too short to display all transition points!';
    }
    state = state.copyWith(duration: newDuration);
  }

  void updateTickFrequency(int newTickFrequency) {
    if (newTickFrequency > state.duration) {
      throw 'Tick frequency must be less than duration!';
    }
    var allTransitionPointsAligned = state.values
        .map((v) => v.tick)
        .every((point) => _intersectsTicks(point, newTickFrequency));
    if (!allTransitionPointsAligned) {
      throw 'Some transition points do not intersect with the new tick frequency!';
    }
    state = state.copyWith(tickFrequency: newTickFrequency);
  }

  void updateTransitionPoint(int pointIndex, int newValue) {
    if (pointIndex < 0 || pointIndex >= state.values.length) {
      return;
    }
    _ensureTransitionPointRulesFulfilled(newValue);
    var newPoints = [...state.values];
    newPoints[pointIndex] = newPoints[pointIndex].copyWith(tick: newValue);
    state = state.copyWith(values: _sortAndUnique(newPoints));
  }

  void removeTransitionPoint(int pointIndex) {
    if (pointIndex < 0 || pointIndex >= state.values.length) {
      return;
    }

    var newPoints = [...state.values];
    newPoints.removeAt(pointIndex);
    state = state.copyWith(values: _sortAndUnique(newPoints));
  }

  void addTransitionPoint(int value) {
    _ensureTransitionPointRulesFulfilled(value);
    var newPoints = [...state.values, WaveFormValue(tick: value, value: 100.0)];
    state = state.copyWith(values: _sortAndUnique(newPoints));
  }

  void reset() {
    state = _initialState;
  }

  List<WaveFormValue> _sortAndUnique(List<WaveFormValue> values) {
    values.sort((a, b) => a.tick < b.tick ? -1 : 1);
    return values.toSet().toList();
  }

  bool _intersectsTicks(int point, int tickFrequency) {
    return tickFrequency == 0 ? false : point % tickFrequency == 0;
  }

  void _ensureTransitionPointRulesFulfilled(int value) {
    if (!_intersectsTicks(value, state.tickFrequency)) {
      throw 'Transition point must intersect with a tick!';
    }
    if (value < 0 || value > state.duration) {
      throw 'Can not add transition point outside the duration window!';
    }
    if (value == 0) {
      throw 'Can not add transition point on the first tick!';
    }
    if (value == state.duration) {
      throw 'Can not add transition point on the last tick!';
    }
  }
}
