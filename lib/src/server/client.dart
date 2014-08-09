part of wamp.server;

/// Represents a client connection.
class Client {
  String sessionId;
  WebSocket socket;

  Set<String> topics = new Set();
  Map<String, String> prefixes = new Map();

  Client(this.socket, this.sessionId) {
    var rnd = new Random();
  }

  void send(msg) {
    socket.add(JSON.encode(msg));
  }

  void welcome([serverId = "srv"]) {
    send([MessageType.WELCOME, sessionId, PROTOCOL_VERSION, serverId]);
  }

  void callResult(String callId, result) {
    send([MessageType.CALL_RESULT, callId, result]);
  }

  void callError(String callId, String errorUri, String errorDescription) {
    send([MessageType.CALL_ERROR, callId, errorUri, errorDescription]);
  }

  void event(String topicId, event) {
    send([MessageType.EVENT, topicId, event]);
  }
}
