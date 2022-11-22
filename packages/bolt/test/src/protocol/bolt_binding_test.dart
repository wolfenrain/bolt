import 'package:bolt/bolt.dart';
import 'package:test/test.dart';

class _TestBinding extends BoltBinding {
  @override
  Future<void> bind() {
    throw UnimplementedError();
  }

  @override
  bool isAwareOff(Address address) {
    throw UnimplementedError();
  }

  @override
  Stream<Packet<List<int>>> get rawPackets => throw UnimplementedError();

  @override
  void send(List<int> data, Address address) {
    throw UnimplementedError();
  }

  @override
  Future<void> unbind() {
    throw UnimplementedError();
  }
}

void main() {
  group('BoltBinding', () {
    test('can be instantiated', () {
      final binding = _TestBinding();

      expect(binding, isNotNull);
    });
  });
}
