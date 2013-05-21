part of wamp;

const int PROTOCOL_VERSION = 1;

abstract class WampProtocol {
  static const String URI_WAMP_BASE = "http://api.wamp.ws/";
  static const String URI_WAMP_PROCEDURE = "http://api.wamp.ws/procedure#";
}

/**
 * WAMP defines the message types which are used in the communication between
 * two WebSocket endpoints, the client and the server, and describes associated
 * semantics.
 */
abstract class MessageType {
  // Auxiliary messages.
  static const int WELCOME = 0;
  static const int PREFIX = 1;

  // Remote procedure calls.
  static const int CALL = 2;
  static const int CALL_RESULT = 3;
  static const int CALL_ERROR = 4;

  // Publish & subscribe.
  static const int SUBSCRIBE = 5;
  static const int UNSUBSCRIBE = 6;
  static const int PUBLISH = 7;
  static const int EVENT = 8;
}