library wamp.server;

import 'dart:io';
import 'dart:json';
import 'dart:math';
import 'package:wamp/wamp.dart';

part 'src/server/client.dart';

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

//    conn.onClosed = (e) {
//      clients.remove(c);
//    };
  }

  void onCall(Client c, String callId, String uri, String arg) {
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
    var uri = curie.decode(topicUri);

    clients.forEach((client) {
      client.event(topicUri, event);
    });
  }
}