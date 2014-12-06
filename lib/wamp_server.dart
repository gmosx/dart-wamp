library wamp.server;

import 'dart:io';
import 'dart:convert' show JSON;
import 'dart:math';
import 'dart:async';

import 'package:wamp/wamp.dart';
import 'package:uuid/uuid_server.dart';

part 'src/server/client.dart';

/// Server-side handler for wamp connections.
class WampHandler implements StreamConsumer {
  Set<Client> clients = new Set();
  Map<String, Set<Client>> topicMap = new Map();
  CurieCodec curie = new CurieCodec();

  Future addStream(Stream<WebSocket> stream) {
    stream.listen((socket) {
      handle(socket);
    });
    return new Future.value(stream); // TODO: what to return here?
  }

  Future close() {
    return new Future.value(); // TODO: what to do here?
  }

  void handle(WebSocket socket) {
    var c = new Client(socket, generateSessionId())..welcome();

    clients.add(c);

    socket.listen((data) {
      var msg;

      try {
        msg = JSON.decode(data);

        switch(msg[0]) {
          case MessageType.PREFIX:
            c.prefixes[msg[1]] = msg[2];
            break;

          case MessageType.CALL:
            onCall(c, msg[1], msg[2], msg[3]);
            break;

          case MessageType.SUBSCRIBE:
            onSubscribe(c, msg[1]);
            break;

          case MessageType.UNSUBSCRIBE:
            onUnsubscribe(c, msg[1]);
            break;

          case MessageType.PUBLISH:
            onPublish(c, msg[1], msg[2]/*, msg[3], msg[4]*/);
            break;
        }
      } on FormatException {
        socket.close(WebSocketStatus.UNSUPPORTED_DATA, "Received data is not a valid JSON");
      }
    }, onDone: () {
      // Make a copy because unsubscription removes the topics from the client
      (new Set.from(c.topics)).forEach((t) => unsubscribe(c, t));
      clients.remove(c);
      onDone(c);
    });
  }

  /// Handles Remote Procedure Calls (RPC).
  /// To be overridden by subclasses.
  void onCall(Client c, String callId, String uri, arg){}

  /// Handles the closing of a websocket listener.
  /// To be overridden by subclasses.
  void onDone(Client c){}

  /// Handles subscription events.
  void onSubscribe(Client c, String topicUri) {
    subscribe(c, topicUri);
  }

  /// Handles unsubscription events.
  void onUnsubscribe(Client c, String topicUri) {
    unsubscribe(c, topicUri);
  }

  /// Handles publication events.
  void onPublish(Client c, String topicUri, event, [exclude, eligible]) { // TODO: handle exclude, eligible.
    publish(topicUri, event);
  }

  /// Subscribes [c] to [topicUri].
  void subscribe(Client c, String topicUri) {
    var uri = curie.decode(topicUri);

    c.topics.add(uri);

    if (!topicMap.containsKey(uri)) {
      topicMap[uri] = new Set();
    }

    topicMap[uri].add(c);
  }

  /// Unsubscribes [c] from [topicUri].
  void unsubscribe(Client c, String topicUri) {
    var uri = curie.decode(topicUri);

    c.topics.remove(uri);

    if (topicMap.containsKey(uri)) {
      topicMap[uri].remove(c);
      if (topicMap[uri].isEmpty) topicMap.remove(uri);
    }
  }

  /// Sends an event to all the subscribed clients.
  void publish(String topicUri, event) {
    final uri = curie.decode(topicUri);

    if (topicMap.containsKey(uri)) {
      final subscribers = topicMap[uri];

      subscribers.forEach((client) {
        if (clients.contains(client)) {
          client.event(topicUri, event);
        }
      });
    }
  }

  /// Generates an id for a client connection. By default uses UUID.v4, but
  /// can be overridden to return custom ids.
  String generateSessionId() {
    return new Uuid().v4();
  }
}