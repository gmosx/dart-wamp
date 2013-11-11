import 'dart:html';
import 'package:wamp/wamp_client.dart';

class ChatClient extends WampClient {
  ChatClient(socket) : super(socket);

  onWelcome() {
    subscribe('chat:room');
  }

  onEvent(topicUri, event) {
    querySelector('#history').appendHtml('${event}<br />');
  }
}

void main() {
  var socket = new WebSocket('ws://127.0.0.1:8080/ws'),
      client = new ChatClient(socket);

  var sendButton = querySelector('#send'),
      prompt = querySelector('#prompt') as InputElement;

  sendButton.onClick.listen((e) {
    client.publish('chat:room', prompt.value, true);
    prompt.value = '';
  });
}