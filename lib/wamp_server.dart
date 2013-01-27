library wamp.server;

import 'dart:io';
import 'dart:json' as JSON;
import 'dart:math';
import 'dart:async';
import 'package:wamp/wamp.dart';

part 'src/server/client.dart';

/**
 * Handler for wamp connections.
 */
class WampHandler {
  Set<Client> clients = new Set();
  Map<String, Set<Client>> topicMap = new Map();
  CurieCodec curie = new CurieCodec();

  onOpen(WebSocketConnection conn) {
    var c = new Client(conn)
        ..welcome();

    clients.add(c);

    conn.onClosed = (int status, String reason) {
      clients.remove(c);
    };

    conn.onMessage = (m) {
      var msg = JSON.parse(m);

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

    };
  }

  void onCall(Client c, String callId, String uri, arg) {
  }

  void onSubscribe(Client c, String topicUri) {
    var uri = curie.decode(topicUri);

    c.topics.add(uri);

    if (!topicMap.containsKey(uri)) {
      topicMap[uri] = new Set();
    }
    topicMap[uri].add(c);
  }

  void onUnsubscribe(Client c, String topicUri) {
    var uri = curie.decode(topicUri);

    c.topics.remove(uri);

    if (topicMap.containsKey(uri)) {
      topicMap[uri].remove(c);
      if (topicMap[uri].isEmpty) topicMap.remove(uri);
    }
  }

  void onPublish(Client c, String topicUri, event, [exclude, eligible]) {
    // TODO: handle exclude, eligible.
    publish(topicUri, event);
  }

  /**
   * Publish an event to all the subscribed clients.
   */
  void publish(String topicUri, event) {
    final uri = curie.decode(topicUri),
          subscribers = topicMap[uri],
          garbage = [];

    subscribers.forEach((client) {
      if (clients.contains(client)) {
        client.event(topicUri, event);
      } else {
        // The client is disconnected, so gc.
        garbage.add(client);
      }
    });

    // TODO: perfome gc when the client is disconnected?
    if (!garbage.isEmpty) {
      garbage.forEach((c) => clients.remove(c));
    }
  }
}