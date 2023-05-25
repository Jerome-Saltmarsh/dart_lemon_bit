import 'dart:io';

import 'package:bleed_server/src/classes/src/player.dart';
import 'package:bleed_server/src/classes/src/server_base.dart';

class UDPClient {
  Player? player;
  InternetAddress address;
  int port;

  UDPClient(this.address, this.port);
}

class UdpServer extends ServerBase {
  final clients = <UDPClient>[];
  late final RawDatagramSocket socket;

  void start() async {

    socket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, 8080);
    print('UDP Game Server started on ${socket.address.address}:${socket.port}');

    socket.listen((RawSocketEvent event) {
      if (event == RawSocketEvent.read) {
        final datagram = socket.receive();
        if (datagram == null) return;
        final client = findOrCreateClient(datagram.address, datagram.port);
        final data = datagram.data;
      }
    });
  }

  void handleGameLogic(InternetAddress address, int port, String message, RawDatagramSocket socket, List<UDPClient> clients) {
    // Find or create the client
    final client = findOrCreateClient(address, port);

    // Process the received message and send a response to all clients
    String response = 'Game Logic: $message';
    socket.send(response.codeUnits, client.address, client.port);
  }

  UDPClient findOrCreateClient(InternetAddress address, int port) {
    for (final client in clients) {
      if (client.address == address && client.port == port) {
        return client;
      }
    }

    final newClient = UDPClient(address, port);
    clients.add(newClient);
    print("new client connected");
    return newClient;
  }

  @override
  void sendResponseToClients() {
    for (final client in clients) {
      final player = client.player;
      if (player == null) continue;
      socket.send(player.compile(), client.address, client.port);
    }
  }
}

