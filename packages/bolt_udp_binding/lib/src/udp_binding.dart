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

        final address = Address(datagram.address.host, datagram.port);
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
  bool isAwareOff(Address address) {
    // If the list of addresses is empty, we assume that we are the client and
    // that we are aware of the server.
    if (_addresses.isEmpty) return true;

    // If the host is '0.0.0.0' we should also check the localhost address.
    // This is because if the host is 'localhost' the UDP socket will report the
    // address as '127.0.0.1' and not '0.0.0.0'.
    if (address.host == '0.0.0.0') {
      final localVersion = Address('127.0.0.1', address.port);
      return _addresses.contains(localVersion) || _addresses.contains(address);
    }
    return _addresses.contains(address);
  }
}
