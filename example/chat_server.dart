import 'dart:io';
import 'package:wamp/wamp_server.dart';

class ChatHandler extends WampHandler {
  void onCall(c, callId, uri, arg) {
    c.callResult(callId, "RPC message accepted: $uri");
  }
}

void main() {
  final chatHandler = new ChatHandler();

  HttpServer.bind('127.0.0.1', 8080).then((HttpServer server) {
    server.where((request) => request.uri.path == '/ws')
          .transform(new WebSocketTransformer(protocolSelector: (_) => 'wamp'))
          .pipe(chatHandler);
  });
}
