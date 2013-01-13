import 'dart:html';
import 'package:wamp/wamp_client.dart';

class ChatClient extends WampClient {
  ChatClient(ws) : super(ws);

  onWelcome() {
  }

  onEvent(topicUri, event) {
    query('#history').appendHtml('${event}<br />');
  }
}

void main() {
  var ws = new WebSocket('ws://127.0.0.1:8080/ws'),
      client = new ChatClient(ws);

  var sendButton = query('#send'),
      prompt = query('#prompt') as InputElement;

  sendButton.on.click.add((e) {
    client.publish('chat:room', prompt.value, true);
    prompt.value = '';
  });
}