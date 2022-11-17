import 'dart:async';
import 'dart:io';

import 'package:bolt/bolt.dart';

/// {@template udp_binding}
/// A binding that uses UDP to send and receive packets.
///
/// This can be used by both the client and the server.
/// {@endtemplate}
class UdpBinding extends BoltBinding {
  /// {@macro udp_binding}
  UdpBinding(
    this.address, {
    super.logger,
  }) : _packetController = StreamController.broadcast();

  /// The address to bind to.
  final Address address;

  @override
  Stream<Packet<List<int>>> get rawPackets => _packetController.stream;
  final StreamController<Packet<List<int>>> _packetController;

  RawDatagramSocket? _udpSocket;

  final Set<Address> _addresses = {};

  @override
  Future<void> bind() async {
    if (_udpSocket != null) return;

    final hosts = await InternetAddress.lookup(address.host);
    _udpSocket = await RawDatagramSocket.bind(hosts.first, address.port);
    logger.detail('Listening on ${_udpSocket!.address}:${_udpSocket!.port}');

    _udpSocket!.listen((event) {
      if (event == RawSocketEvent.read) {
        final datagram = _udpSocket!.receive();
        if (datagram == null) return;

        final address = Address(datagram.address.address, datagram.port);
        _addresses.add(address);
        logger.detail('Received data from $address');
        _packetController.add(Packet(address, datagram.data));
      }
    });
  }

  @override
  Future<void> unbind() async {
    _udpSocket?.close();
    _udpSocket = null;
  }

  @override
  void send(List<int> data, Address address) {
    logger.detail('Sending data to $address');
    _udpSocket?.send(
      data,
      // TODO(wolfen): this wont support domain names, only ip addresses
      InternetAddress.tryParse(address.host)!,
      address.port,
    );
  }

  @override
  bool isAwareOff(Address address) => _addresses.contains(address);
}
