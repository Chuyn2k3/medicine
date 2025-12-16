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

  String statusMessage = 'Chưa kết nối';
  bool isConnecting = false;

  String logSsid = '';
  String logPassword = '';

  void connectToWiFi() async {
    final ssid = ssidController.text;
    final password = passwordController.text;

    setState(() {
      isConnecting = true;
      statusMessage = 'Đang kết nối...';
      logSsid = ssid;
      logPassword = password;
    });

    // Show snackbar khi bấm connect
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Đang gửi thông tin Wi-Fi tới ESP32...')),
    );

    final url = Uri.parse("http://192.168.4.1/wifi");

    final jsonData = jsonEncode({
      'ssid': ssid,
      'pass': password,
    });

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonData,
      );

      if (response.statusCode == 200) {
        setState(() {
          statusMessage = '✅ Kết nối Wi-Fi thành công';
          isConnecting = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Kết nối Wi-Fi thành công!')),
        );
      } else {
        setState(() {
          statusMessage = '❌ Lỗi kết nối: ${response.statusCode}';
          isConnecting = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Không thể kết nối Wi-Fi')),
        );
      }
    } catch (e) {
      setState(() {
        statusMessage = '❌ Lỗi: $e';
        isConnecting = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi kết nối ESP32')),
      );
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
          crossAxisAlignment: CrossAxisAlignment.start,
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
              onPressed: isConnecting ? null : connectToWiFi,
              child: isConnecting
                  ? SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text('Kết nối Wi-Fi'),
            ),

            SizedBox(height: 30),

            // ===== TRẠNG THÁI =====
            Text(
              'Trạng thái:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              statusMessage,
              style: TextStyle(
                color: statusMessage.contains('thành công')
                    ? Colors.green
                    : statusMessage.contains('Lỗi')
                        ? Colors.red
                        : Colors.black,
              ),
            ),

            Divider(height: 30),

            // ===== LOG NGƯỜI DÙNG NHẬP =====
            Text(
              'Log thông tin đã nhập:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text('SSID: $logSsid'),
            Text('Password: $logPassword'),
          ],
        ),
      ),
    );
  }
}
