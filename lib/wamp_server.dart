library wamp.server;

import 'dart:io';
import 'dart:json' as JSON;
import 'dart:math';
import 'dart:async';
import 'package:wamp/wamp.dart';

part 'src/server/client.dart';

/**
 * Server-side handler for wamp connections.
 */
class WampHandler {
  Set<Client> clients = new Set();
  Map<String, Set<Client>> topicMap = new Map();
  CurieCodec curie = new CurieCodec();
  
  void handle(WebSocket socket) {
    var c = new Client(socket)..welcome();

    clients.add(c);

    socket.listen((data) {
      final msg = JSON.parse(data);

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
    }, onDone: () {
      c.topics.forEach((t) => _unsubscribe(c, t));
      clients.remove(c);
    });
  }

  /**
   * To be overriden by subclasses.
   */
  void onCall(Client c, String callId, String uri, arg) {
  }

  /**
   * Handle subscription events.
   */
  void onSubscribe(Client c, String topicUri) {
    var uri = curie.decode(topicUri);

    c.topics.add(uri);

    if (!topicMap.containsKey(uri)) {
      topicMap[uri] = new Set();
    }

    topicMap[uri].add(c);
  }

  void onUnsubscribe(Client c, String topicUri) {
    final uri = curie.decode(topicUri);
    c.topics.remove(uri);

    _unsubscribe(c, topicUri);
  }

  void onPublish(Client c, String topicUri, event, [exclude, eligible]) { // TODO: handle exclude, eligible.
    publish(topicUri, event);
  }

  void _unsubscribe(Client c, String topicUri) {
    var uri = curie.decode(topicUri);

    if (topicMap.containsKey(uri)) {
      topicMap[uri].remove(c);
      if (topicMap[uri].isEmpty) topicMap.remove(uri);
    }
  }

  /**
   * Publish an event to all the subscribed clients.
   */
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
}