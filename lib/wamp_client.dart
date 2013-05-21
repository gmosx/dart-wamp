library wamp.client;

import 'dart:html';
import 'dart:json' as JSON;
import 'dart:math';
import 'dart:crypto';
import 'dart:async';
import 'package:wamp/wamp.dart';

// TODO: add reconnect functionality.

/**
 * WAMP client.
 */
class WampClientProtocol {
  WebSocket _socket;

  String sessionId;
  Map<String, String> prefixes = new Map();
  Map<String, Completer> callCompleters = new Map();

  WampClientProtocol(this._socket) {
    _socket.onMessage.listen((e) => onMessage(JSON.parse(e.data)));
  }

  void onMessage(msg) {
    switch (msg[0]) {
      case MessageType.WELCOME:
        sessionId = msg[1];
        onOpenSession();
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
    _socket.send(JSON.stringify(msg));
  }

  void onOpenSession() {
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
  Future call(uri, args) {
    var rnd = new Random(), // TODO: Extract this!
        callId = rnd.nextInt(99999).toString(); // TODO: use some kind of hash.

    var completer = new Completer();

    callCompleters[callId] = completer;

    var msg = [MessageType.CALL, callId, uri];
    if (args is List) {
      msg.addAll(args);
    } else {
      msg.add(args);
    }
    send(msg);

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

class WampCraClientProtocol extends WampClientProtocol {

  WampCraClientProtocol(socket) : super(socket);

  /*
   * Authenticate the WAMP session to server.
   */
  Future authenticate({authKey: "", authExtra: "", authSecret: ""}) {
    Future authreq = call(WampProtocol.URI_WAMP_PROCEDURE + "authreq", authKey);
    authreq.then((challenge) {
      String sig = authSignature(challenge, authSecret);
      Future auth = call(WampProtocol.URI_WAMP_PROCEDURE + "auth", sig);
      return auth;
    });
    return authreq;
  }

  /*
   * Compute the authentication signature from an authentication challenge and a secret.
   */
  String authSignature(authChallenge, authSecret, [authExtra]) {
    HMAC hash = new HMAC(new SHA256(), authSecret.codeUnits);
    hash.add(authChallenge.codeUnits);
    return CryptoUtils.bytesToBase64(hash.digest);
  }

}