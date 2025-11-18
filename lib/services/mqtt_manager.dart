import 'dart:convert';
import 'dart:typed_data';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:mqtt5_client/mqtt5_client.dart';
import 'package:mqtt5_client/mqtt5_server_client.dart';

class MqttManager {
  static const String _brokerUrl = 'medicine-mqtt.huy.lat';
  static const int _port = 8883;
  static const String _topic = 'medicine/control';

  late MqttServerClient _client;
  bool _isConnected = false;
  bool _isCertificateLoaded = false;

  MqttManager() {
    _client = MqttServerClient.withPort(
      _brokerUrl,
      'medicine_app_${DateTime.now().millisecondsSinceEpoch}',
      _port,
    );

    _client.secure = true;
    _client.securityContext = SecurityContext.defaultContext;
    _client.onConnected = _onConnected;
    _client.onDisconnected = _onDisconnected;
    _client.logging(on: true);
  }

  /// Load certificate từ assets
  Future<void> init() async {
    if (_isCertificateLoaded) return;

    try {
      ByteData data = await rootBundle.load('assets/cert/isrgrootx1.pem');
      final bytes = data.buffer.asUint8List();
      _client.securityContext.setTrustedCertificatesBytes(bytes);
      _isCertificateLoaded = true;
      print('Certificate loaded from assets');
    } catch (e) {
      print('Error loading certificate: $e');
    }
  }

  /// Connect MQTT, đảm bảo certificate đã load
  Future<bool> connect() async {
    if (_isConnected) return true;

    try {
      if (!_isCertificateLoaded) await init();

      await _client.connect();
      return _isConnected;
    } catch (e) {
      print('MQTT Connection Error: $e');
      _isConnected = false;

      // Thử reconnect sau 5 giây
      Future.delayed(const Duration(seconds: 5), () => connect());
      return false;
    }
  }

  void _onConnected() {
    _isConnected = true;
    print('MQTT Connected');
  }

  void _onDisconnected() {
    _isConnected = false;
    print('MQTT Disconnected. Reconnecting...');
    Future.delayed(const Duration(seconds: 5), () => connect());
  }

  Future<void> publishMedicineControl(Map<String, int> medicines) async {
    if (!_isConnected) await connect();

    final payload = jsonEncode(medicines);
    final builder = MqttPayloadBuilder();
    builder.addString(payload);

    try {
      _client.publishMessage(_topic, MqttQos.atLeastOnce, builder.payload!);
      print('Published to $_topic: $payload');
    } catch (e) {
      print('Error publishing message: $e');
    }
  }

  void disconnect() {
    _client.disconnect();
    _isConnected = false;
  }

  bool get isConnected => _isConnected;
}
