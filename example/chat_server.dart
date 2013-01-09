import 'dart:io';
import 'package:wamp/server.dart';

class ChatHandler extends WampHandler {
  void onCall(c, callId, uri, arg) {
    c.callResult(callId, 'It fuckin works');
  }
}

void main() {
  HttpServer server = new HttpServer();

  server.onError = (error) => print(error);
  server.listen('127.0.0.1', 8080);

  WebSocketHandler wsHandler = new WebSocketHandler();
  wsHandler.onOpen = new ChatHandler().onOpen;

  server.addRequestHandler((req) => req.path == "/ws", wsHandler.onRequest);
}