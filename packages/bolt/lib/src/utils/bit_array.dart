/// {@template bit_array}
/// A bit array that can be used to store bits.
/// {@endtemplate}
class BitArray {
  /// {@macro bit_array}
  BitArray(this.size)
      : assert(size > 0, 'size must be greater than 0'),
        bytes = 8 * ((size ~/ 64) + ((size % 64 != 0) ? 1 : 0)) {
    assert(bytes > 0, 'bytes must be greater than 0');
    assert((bytes % 8) == 0, 'bytes must be a multiple of 8');
    clear();
  }

  /// The size of the bit array.
  final int size;

  /// The number of bytes in the bit array.
  final int bytes;

  late List<int> _data;

  /// Clears the bit array.
  void clear() => _data = List.filled(bytes ~/ 8, 0);

  /// Sets the bit at [index] to 1.
  void setBit(int index) {
    assert(index >= 0, 'index must be >= 0');
    assert(index < size, 'index must be < size');
    final dataIndex = index >> 6;
    final bitIndex = index & ((1 << 6) - 1);
    assert(bitIndex >= 0, 'bitIndex must be >= 0');
    assert(bitIndex < 64, 'bitIndex must be < 64');
    _data[dataIndex] |= 1 << bitIndex;
  }

  /// Sets the bit at [index] to 0.
  void clearBit(int index) {
    assert(index >= 0, 'index must be >= 0');
    assert(index < size, 'index must be < size');
    final dataIndex = index >> 6;
    final bitIndex = index & ((1 << 6) - 1);
    _data[dataIndex] &= ~(1 << bitIndex);
  }

  /// Returns the bit at [index].
  bool getBit(int index) {
    assert(index >= 0, 'index must be >= 0');
    assert(index < size, 'index must be < size');
    final dataIndex = index >> 6;
    final bitIndex = index & ((1 << 6) - 1);
    assert(bitIndex >= 0, 'bitIndex must be >= 0');
    assert(bitIndex < 64, 'bitIndex must be < 64');
    return ((_data[dataIndex] >> bitIndex) & 1) == 1;
  }
}
