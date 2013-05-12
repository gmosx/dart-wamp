part of wamp.server;

class Client {
  String sessionId;
  WebSocket socket;

  Set<String> topics = new Set();
  Map<String, String> prefixes = new Map();

  Client(this.socket) {
    var rnd = new Random();
    sessionId = rnd.nextInt(99999).toString(); // TODO: use some kind of hash.
  }

  void send(msg) {
    socket.add(JSON.stringify(msg));
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
