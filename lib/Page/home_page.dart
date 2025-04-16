import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tte/mqtt_config.dart';
import 'package:tte/widgets/control_button.dart';
import 'package:tte/widgets/device_status_widgets.dart';
import 'package:tte/mqtt_app_state.dart' as mqttState;


class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  void initState() {
    super.initState();
    final mqttAppState = Provider.of<mqttState.MQTTAppState>(context, listen: false);
    mqttAppState.connect();
  }

  @override
  void dispose() {
    final mqttAppState = Provider.of<mqttState.MQTTAppState>(context, listen: false);
    mqttAppState.disconnect();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mqttAppState = Provider.of<mqttState.MQTTAppState>(context);
    final isDeviceOn = mqttAppState.latestStatusMessage?["params"]?["Status"] == 1;
    final isOnline = mqttAppState.latestStatusMessage?["params"]?["IsOnlie"] == 1;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('TTE', style: TextStyle(color: Colors.black)),
        centerTitle: true,
        actions: [
          Consumer<mqttState.MQTTAppState>(
            builder: (context, mqttAppState, _) {
              return IconButton(
                icon: Icon(
                  mqttAppState.isConnected ? Icons.wifi : Icons.wifi_off,
                  color: mqttAppState.isConnected ? Colors.green : Colors.red,
                ),
                onPressed: () {
                  if (mqttAppState.isConnected) {
                    mqttAppState.disconnect();
                    _showSnackbar('Đã ngắt kết nối MQTT', Colors.red);
                  } else {
                    mqttAppState.connect();
                    _showSnackbar('Đang kết nối lại MQTT...', Colors.blue);
                  }
                },
              );
            },
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final availableHeight = constraints.maxHeight;
          const headerHeight = 300.0;
          return Column(
            children: [
              _buildHeader(isOnline, isDeviceOn, mqttAppState),
              const Expanded(child: DeviceCardSelector()),
            ],
          );
        },
      ),
    );
  }

  void _showSnackbar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Widget _buildHeader(bool isOnline, bool isDeviceOn, mqttState.MQTTAppState mqttAppState) {
    return Container(
      height: 300.0,
      width: double.infinity,
      color: const Color.fromARGB(255, 73, 133, 182),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Thiết bị', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        Row(
                          children: [
                            Icon(Icons.circle, size: 12, color: isOnline ? Colors.green : Colors.red),
                            const SizedBox(width: 8),
                            Text(
                              isDeviceOn ? 'Bật' : 'Tắt',
                              style: TextStyle(
                                color: isDeviceOn ? Colors.green : Colors.red,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    if (mqttAppState.connectionState != null && !mqttAppState.isConnected)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(mqttAppState.connectionState!, style: const TextStyle(color: Colors.red)),
                      ),
                  ],
                ),
              ),
            ),
          ),
          _buildControlButtons(mqttAppState),
        ],
      ),
    );
  }

  Widget _buildControlButtons(mqttState.MQTTAppState mqttAppState) {
    return Container(
      color: const Color(0xFFC7D8FF),
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          ControlButton(
            icon: Icons.flash_on,
            onPressed: !mqttAppState.isConnected ? null : () {
              mqttAppState.updateDeviceState(true);
              _showSnackbar('Đã gửi lệnh bật thiết bị', Colors.green);
            },
            text: "BẬT",
            backgroundColor: Colors.green,
          ),
          ControlButton(
            icon: Icons.flash_off,
            onPressed: !mqttAppState.isConnected ? null : () {
              mqttAppState.updateDeviceState(false);
              _showSnackbar('Đã gửi lệnh tắt thiết bị', Colors.red);
            },
            text: "TẮT",
            backgroundColor: Colors.red,
          ),
          ControlButton(
            icon: Icons.find_replace,
            onPressed: !mqttAppState.isConnected ? null : () {
              try {
                mqttAppState.publishMessage(7, MQTTConfig.DeviceId, MQTTConfig.devicePassword);
                Future.delayed(const Duration(milliseconds: 500), () {
                  if (mounted && mqttAppState.isConnected) {
                    mqttAppState.publishMessage(5, MQTTConfig.DeviceId, MQTTConfig.devicePassword);
                  }
                });
                _showSnackbar('Đang làm mới dữ liệu...', Colors.pink);
              } catch (e) {
                _showSnackbar('Lỗi khi làm mới: $e', Colors.red);
              }
            },
            text: "LÀM MỚI",
            backgroundColor: Colors.pink,
          ),
          ControlButton(
            icon: Icons.replay_circle_filled_outlined,
            onPressed: !mqttAppState.isConnected ? null : () {
              try {
                mqttAppState.publishMessage(4, MQTTConfig.DeviceId, MQTTConfig.devicePassword);
                _showSnackbar('Đã gửi lệnh khôi phục', Colors.blue);
              } catch (e) {
                _showSnackbar('Lỗi khi khôi phục: $e', Colors.red);
              }
            },
            text: "KHÔI PHỤC",
            backgroundColor: Colors.blue,
          ),
          ControlButton(
            icon: Icons.timer,
            onPressed: () {
              _showSnackbar('Chức năng hẹn giờ chưa được triển khai', Colors.yellow);
            },
            text: "HẸN GIỜ",
            backgroundColor: Colors.yellow,
          ),
        ],
      ),
    );
  }
}
