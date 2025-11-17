import 'dart:convert';
import 'package:mqtt5_client/mqtt5_client.dart';
import 'package:mqtt5_client/mqtt5_server_client.dart';

class MqttManager {
  static const String _brokerUrl = 'medicine-mqtt.huy.lat';
  static const int _port = 8883;
  static const String _topic = 'medicine/control';

  late MqttServerClient _client;
  bool _isConnected = false;

  MqttManager() {
    _client = MqttServerClient.withPort(
      _brokerUrl,
      'medicine_app_${DateTime.now().millisecondsSinceEpoch}',
      _port,
    );
    _client.secure = true;
    _client.onConnected = _onConnected;
    _client.onDisconnected = _onDisconnected;
  }

  Future<bool> connect() async {
    try {
      await _client.connect();
      return _isConnected;
    } catch (e) {
      print('MQTT Connection Error: $e');
      _isConnected = false;
      return false;
    }
  }

  void _onConnected() {
    _isConnected = true;
    print('MQTT Connected');
  }

  void _onDisconnected() {
    _isConnected = false;
    print('MQTT Disconnected');
  }

  Future<void> publishMedicineControl(Map<String, int> medicines) async {
    if (!_isConnected) {
      await connect();
    }

    try {
      final payload = jsonEncode(medicines);
      final builder = MqttPayloadBuilder();
      builder.addString(payload);

      _client.publishMessage(
        _topic,
        MqttQos.atLeastOnce,
        builder.payload!,
      );
      print('Published to $_topic: $payload');
    } catch (e) {
      print('Error publishing message: $e');
    }
  }

  Future<void> disconnect() async {
    _client.disconnect();
    _isConnected = false;
  }

  bool get isConnected => _isConnected;
}
