import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class WifiControllerPage extends StatefulWidget {
  @override
  _WifiControllerPageState createState() => _WifiControllerPageState();
}

class _WifiControllerPageState extends State<WifiControllerPage> {
  TextEditingController ssidController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  void connectToWiFi() async {
    var ssid = ssidController.text;
    var password = passwordController.text;

    // Địa chỉ IP của ESP32 (của AP ESP32)
    var url = Uri.parse("http://192.168.4.1/wifi");

    // Tạo JSON payload
    var jsonData = jsonEncode({
      'ssid': ssid,
      'pass': password,
    });

    try {
      // Gửi POST request
      var response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonData,
      );

      if (response.statusCode == 200) {
        // Kết nối thành công
        print("Kết nối Wi-Fi thành công!");
        print(response.body);
      } else {
        // Lỗi khi kết nối
        print("Không thể kết nối! Lỗi: ${response.body}");
      }
    } catch (e) {
      print("Lỗi: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Điều khiển Wi-Fi ESP32"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: ssidController,
              decoration: InputDecoration(labelText: 'SSID Mạng Wi-Fi'),
            ),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: InputDecoration(labelText: 'Mật khẩu Wi-Fi'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: connectToWiFi,
              child: Text('Kết nối Wi-Fi'),
            ),
          ],
        ),
      ),
    );
  }
}
