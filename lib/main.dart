import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tte/widgets/control_button.dart';
import 'mqtt_app_state.dart' as mqttState;
import 'mqtt_config.dart';
import 'widgets/device_status_widgets.dart';
import 'package:flutter/services.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => mqttState.MQTTAppState(),
      child: MaterialApp(
        title: 'TTE Control',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          useMaterial3: true,
        ),
        home: const MyHomePage(),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  void initState() {
    super.initState();
    // Kết nối MQTT khi khởi tạo
    final mqttAppState = Provider.of<mqttState.MQTTAppState>(context, listen: false);
    mqttAppState.connect();
  }

  @override
  void dispose() {
    // Ngắt kết nối khi widget bị hủy
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
        title: const Text(
          'TTE',
          style: TextStyle(color: Colors.black),
        ),
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
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Đã ngắt kết nối MQTT'),
                        backgroundColor: Colors.red,
                        duration: Duration(seconds: 2),
                      ),
                    );
                  } else {
                    mqttAppState.connect();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Đang kết nối lại MQTT...'),
                        backgroundColor: Colors.blue,
                        duration: Duration(seconds: 2),
                      ),
                    );
                  }
                },
              );
            },
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          // Tính chiều cao khả dụng
          final availableHeight = constraints.maxHeight;
          const headerHeight = 300.0; // Header
          const paddingVertical = 32.0; // Padding trên/dưới
          const deviceCardHeight = 80.0; // Ước tính Card trạng thái
          const tabBarHeight = 50.0; // Ước tính TabBar
          const spacing = 16.0; // Khoảng cách

          return Column(
            children: [
              // Header
              Container(
                height: headerHeight,
                width: double.infinity,
                color: const Color.fromARGB(255, 73, 133, 182),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Thiết bị',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.circle,
                                      size: 12,
                                      color: isOnline ? Colors.green : Colors.red,
                                    ),
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
                                child: Text(
                                  mqttAppState.connectionState!,
                                  style: const TextStyle(color: Colors.red),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                   
                    
                  ],
                ),
              ),
                    Container(
                      color: const Color(0xFFC7D8FF),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ControlButton(
                            icon: Icons.flash_on,
                            onPressed: !mqttAppState.isConnected
                                ? null
                                : () {
                                    mqttAppState.updateDeviceState(true);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: const Text(
                                          'Đã gửi lệnh bật thiết bị',
                                          style: TextStyle(color: Colors.black),
                                        ),
                                        duration: const Duration(seconds: 2),
                                        backgroundColor: Colors.green,
                                        behavior: SnackBarBehavior.floating,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                      ),
                                    );
                                  },
                            text: "BẬT",
                            backgroundColor: Colors.green,
                          ),
                          ControlButton(
                            icon: Icons.flash_off,
                            onPressed: !mqttAppState.isConnected
                                ? null
                                : () {
                                    mqttAppState.updateDeviceState(false);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: const Text(
                                          'Đã gửi lệnh tắt thiết bị',
                                          style: TextStyle(color: Colors.black),
                                        ),
                                        duration: const Duration(seconds: 2),
                                        backgroundColor: Colors.red,
                                        behavior: SnackBarBehavior.floating,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                      ),
                                    );
                                  },
                            text: "TẮT",
                            backgroundColor: Colors.red,
                          ),
                          ControlButton(
                            icon: Icons.find_replace,
                            onPressed: !mqttAppState.isConnected
                                ? null
                                : () {
                                    try {
                                      mqttAppState.publishMessage(7, MQTTConfig.DeviceId, MQTTConfig.devicePassword);
                                      Future.delayed(const Duration(milliseconds: 1000), () {
                                        if (mounted && mqttAppState.isConnected) {
                                          mqttAppState.publishMessage(5, MQTTConfig.DeviceId, MQTTConfig.devicePassword);
                                        }
                                      });
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: const Text(
                                            'Đang làm mới dữ liệu...',
                                            style: TextStyle(color: Colors.black),
                                          ),
                                          duration: const Duration(seconds: 2),
                                          backgroundColor: Colors.pink,
                                          behavior: SnackBarBehavior.floating,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                        ),
                                      );
                                    } catch (e) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text('Lỗi khi làm mới: $e'),
                                          backgroundColor: Colors.red,
                                          duration: const Duration(seconds: 2),
                                        ),
                                      );
                                    }
                                  },
                            text: "LÀM MỚI",
                            backgroundColor: Colors.pink,
                          ),
                          ControlButton(
                            icon: Icons.replay_circle_filled_outlined,
                            onPressed: !mqttAppState.isConnected
                                ? null
                                : () {
                                    try {
                                      mqttAppState.publishMessage(4, MQTTConfig.DeviceId, MQTTConfig.devicePassword);
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: const Text(
                                            'Đã gửi lệnh khôi phục',
                                            style: TextStyle(color: Colors.black),
                                          ),
                                          duration: const Duration(seconds: 2),
                                          backgroundColor: Colors.blue,
                                          behavior: SnackBarBehavior.floating,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                        ),
                                      );
                                    } catch (e) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text('Lỗi khi khôi phục: $e'),
                                          backgroundColor: Colors.red,
                                          duration: const Duration(seconds: 2),
                                        ),
                                      );
                                    }
                                  },
                            text: "KHÔI PHỤC",
                            backgroundColor: Colors.blue,
                          ),
                          ControlButton(
                            icon: Icons.timer,
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: const Text(
                                    'Chức năng hẹn giờ chưa được triển khai',
                                    style: TextStyle(color: Colors.black),
                                  ),
                                  duration: const Duration(seconds: 2),
                                  backgroundColor: Colors.yellow,
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              );
                            },
                            text: "HẸN GIỜ",
                            backgroundColor: Colors.yellow,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // Nội dung cố định (không cuộn dọc)
              
              const Expanded(child: DeviceCardSelector()),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSettingRow(String label, dynamic value) {
    String statusText;
    Color statusColor;

    if (value == 0) {
      statusText = 'Tắt';
      statusColor = Colors.red;
    } else if (value == 1) {
      statusText = 'Bật';
      statusColor = Colors.green;
    } else if (value == 2) {
      statusText = 'Cảnh báo';
      statusColor = Colors.orange;
    } else {
      statusText = 'Không xác định';
      statusColor = Colors.grey;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 16),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: statusColor),
            ),
            child: Text(
              statusText,
              style: TextStyle(
                color: statusColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}