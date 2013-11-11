library wamp.client;

import 'dart:html';
import 'dart:convert' show JSON;
import 'dart:math';
import 'dart:async';
import 'package:wamp/wamp.dart';

// TODO: add reconnect functionality.

/**
 * WAMP client.
 */
class WampClient {
  WebSocket _socket;

  String sessionId;
  Map<String, String> prefixes = new Map();
  Map<String, Completer> callCompleters = new Map();

  WampClient(this._socket) {
    _socket.onMessage.listen((e) => onMessage(JSON.decode(e.data)));
  }

  void onMessage(msg) {
    switch (msg[0]) {
      case MessageType.WELCOME:
        sessionId = msg[1];
        onWelcome();
        break;

      case MessageType.CALL_RESULT:
        var completer = callCompleters.remove(msg[1]);

        if (completer != null) {
          completer.complete(msg[2]);
        } else {
          // TODO: handle unknown callId error.
        }
        break;

      case MessageType.CALL_ERROR:
        // TODO: implement me!
        break;

      case MessageType.EVENT:
        onEvent(msg[1], msg[2]);
        break;
    }
  }

  void send(msg) {
    _socket.send(JSON.encode(msg));
  }

  void onWelcome() {
    // Override me!
  }

  void onEvent(String topicUri, event) {
    // Override me!
  }

  /**
   * Set a CURIE prefix.
   */
  void prefix(String prefix, String uri) {
    prefixes[prefix] = uri;
    send([MessageType.PREFIX, prefix, uri]);
  }

  /**
   * A remote procedure call.
   */
  Future call(uri, arg) {
    var rnd = new Random(), // TODO: Extract this!
        callId = rnd.nextInt(99999).toString(); // TODO: use some kind of hash.

    var completer = new Completer();

    callCompleters[callId] = completer;

    send([MessageType.CALL, callId, uri, arg]);

    return completer.future;
  }

  /**
   * Subscribe to the given topic.
   */
  void subscribe(topicUri) {
    send([MessageType.SUBSCRIBE, topicUri]);
  }

  /**
   * Unsubscribe from the given topic.
   */
  void unsubscribe(topicUri) {
    send([MessageType.UNSUBSCRIBE, topicUri]);
  }

  /**
   * Publish an event to the given topic.
   */
  void publish(String topicUri, event, [exclude, eligible]) { // TODO: convert to named parameters.
    send([MessageType.PUBLISH, topicUri, event]); //, exclude, eligible]);
  }
}