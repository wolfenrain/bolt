import 'package:bolt/src/utils/utils.dart';

/// {@template sequence_buffer}
/// A buffer that stores a sequence of type [T].
///
/// The buffer is a fixed size and will overwrite the oldest value when a new
/// value is added. Increasing the [sequence] number when a new value is added.
/// {@endtemplate}
class SequenceBuffer<T extends Object> {
  /// {@macro sequence_buffer}
  SequenceBuffer(this.size, T Function() create)
      : assert(size > 0, 'size must be greater than 0'),
        _entryData = List.generate(size, (_) => create()),
        _exists = BitArray(size) {
    reset();
  }

  /// The size of the buffer.
  final int size;

  /// The current sequence number.
  int get sequence => _sequence;

  bool _firstEntry = true;
  late int _sequence;
  late List<int> _entrySequence;
  final List<T> _entryData;
  final BitArray _exists;

  /// Resets the buffer.
  void reset() {
    _firstEntry = true;
    _sequence = 0;
    _exists.clear();
    _entrySequence = List.filled(size, 0);
  }

  /// Insert a new entry into the buffer.
  T? insert(int sequence) {
    if (_firstEntry) {
      _sequence = sequence + 1;
      _firstEntry = false;
    } else if (_sequenceGreaterThan(sequence + 1, _sequence)) {
      _sequence = sequence + 1;
    } else if (_sequenceLessThan(sequence, _sequence - size)) {
      return null;
    }

    final index = sequence % size;

    _exists.setBit(index);

    _entrySequence[index] = sequence;

    return _entryData[index];
  }

  /// Remove an entry from the buffer.
  void remove(int sequence) {
    _exists.clearBit(sequence % size);
  }

  /// Remove all old entries from the buffer.
  void removeOldEntries() {
    final oldestSequence = _sequence - size;
    for (var i = 0; i < size; ++i) {
      if (_exists.getBit(i) &&
          _sequenceLessThan(_entrySequence[i], oldestSequence)) {
        _exists.clearBit(i);
      }
    }
  }

  /// Check if a given sequence number is available to be used.
  bool isAvailable(int sequence) {
    return !_exists.getBit(sequence % size);
  }

  /// Get the entry index at the given sequence number.
  int getIndex(int sequence) {
    return sequence % size;
  }

  /// Get the entry at the given sequence number.
  T? find(int sequence) {
    final index = sequence % size;
    if (_exists.getBit(index) && _entrySequence[index] == sequence) {
      return _entryData[index];
    } else {
      return null;
    }
  }

  /// Get the entry at the given index.
  T? getAtIndex(int index) {
    assert(index >= 0, 'index must be >= 0');
    assert(index < size, 'index must be < size');
    return _exists.getBit(index) ? _entryData[index] : null;
  }

  bool _sequenceGreaterThan(int s1, int s2) {
    return ((s1 > s2) && (s1 - s2 <= 32768)) ||
        ((s1 < s2) && (s2 - s1 > 32768));
  }

  bool _sequenceLessThan(int s1, int s2) {
    return _sequenceGreaterThan(s2, s1);
  }
}
