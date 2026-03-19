import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../models/irrigation_data.dart';

class WebSocketService {
  final String url;
  WebSocketChannel? _channel;
  final StreamController<IrrigationData> _controller =
  StreamController<IrrigationData>.broadcast();

  Stream<IrrigationData> get stream => _controller.stream;

  WebSocketService({required this.url});

  void connect() {
    _channel = WebSocketChannel.connect(Uri.parse(url));

    _channel!.stream.listen(
          (message) {
        try {
          final decoded = jsonDecode(message);
          final data = IrrigationData.fromJson(decoded);
          _controller.add(data);
        } catch (_) {}
      },
      onError: (_) {},
      onDone: () {},
    );
  }

  void disconnect() {
    _channel?.sink.close();
  }

  void sendCommand(Map<String, dynamic> command) {
    _channel?.sink.add(jsonEncode(command));
  }

  void dispose() {
    disconnect();
    _controller.close();
  }
}