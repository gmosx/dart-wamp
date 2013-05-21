import 'dart:html';
import 'package:wamp/wamp_client.dart';

class ChatClient extends WampClientProtocol {
  ChatClient(socket) : super(socket);

  onOpenSession() {
    subscribe('chat:room');
  }

  onEvent(topicUri, event) {
    query('#history').appendHtml('${event}<br />');
  }
}

void main() {
  var socket = new WebSocket('ws://127.0.0.1:8080/ws'),
      client = new ChatClient(socket);

  var sendButton = query('#send'),
      prompt = query('#prompt') as InputElement;

  sendButton.onClick.listen((e) {
    client.publish('chat:room', prompt.value, true);
    prompt.value = '';
  });
}