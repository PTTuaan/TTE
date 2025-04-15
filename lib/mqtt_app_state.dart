import 'package:flutter/material.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'dart:convert';
import 'dart:math';
import 'mqtt_config.dart';

class MQTTAppState extends ChangeNotifier {
  MqttServerClient? _client;
  bool _isConnected = false;
  String? _connectionState;
  String? _receivedMessage;
  bool _deviceState = false;
  bool _allowAutoUpdate = false;
  Map<String, dynamic>? _latestStatusMessage; // Action 7
  Map<String, dynamic>? _latestFunctionMessage; // Action 12
  Map<String, dynamic>? _latestSettingsMessage; // Action 5
  String? _lastCommandId;
  DateTime? _lastCommandTime;
  int _reconnectAttempts = 0;
  static const int _maxReconnectAttempts = 5;
  static const int _baseReconnectDelaySeconds = 3;

  bool get isConnected => _isConnected;
  String? get connectionState => _connectionState;
  String? get receivedMessage => _receivedMessage;
  bool get deviceState => _deviceState;
  bool get allowAutoUpdate => _allowAutoUpdate;
  Map<String, dynamic>? get latestStatusMessage => _latestStatusMessage;
  Map<String, dynamic>? get latestFunctionMessage => _latestFunctionMessage;
  Map<String, dynamic>? get latestSettingsMessage => _latestSettingsMessage;

  set allowAutoUpdate(bool value) {
    _allowAutoUpdate = value;
    notifyListeners();
  }

  void setDeviceState(bool state) {
    _deviceState = state;
    notifyListeners();
  }

  Future<void> connect() async {
    if (_isConnected) {
      print('🔄 Đã kết nối, bỏ qua yêu cầu kết nối mới');
      return;
    }

    _client = MqttServerClient(MQTTConfig.broker, 'flutter_client_tte_${Random().nextInt(10000)}');
    _client!.port = MQTTConfig.port;
    _client!.logging(on: true); // Bật log để debug
    _client!.keepAlivePeriod = 20; // Gửi PINGREQ mỗi 20 giây
    _client!.autoReconnect = false; // Tự quản lý kết nối lại
    _client!.onDisconnected = _onDisconnected;
    _client!.onConnected = _onConnected;
    _client!.onSubscribed = _onSubscribed;

    final connMess = MqttConnectMessage()
        .withClientIdentifier('flutter_client_tte')
        .authenticateAs(MQTTConfig.username, MQTTConfig.password)
        .startClean()
        .withWillQos(MqttQos.atMostOnce);

    _client!.connectionMessage = connMess;

    try {
      print('🔌 Đang kết nối đến ${MQTTConfig.broker}:${MQTTConfig.port}...');
      await _client!.connect();
      _reconnectAttempts = 0;
      _isConnected = true;
      _connectionState = 'Đã kết nối';
      notifyListeners();
    } catch (e) {
      print('❌ Lỗi kết nối: $e');
      _isConnected = false;
      _connectionState = 'Kết nối thất bại: $e';
      notifyListeners();
      _scheduleReconnect();
    }
  }

  void _onConnected() {
    _isConnected = true;
    _connectionState = 'Đã kết nối';
    _reconnectAttempts = 0;
    print('✅ Đã kết nối đến MQTT');
    publishMessage(7, MQTTConfig.DeviceId, MQTTConfig.devicePassword);
    Future.delayed(const Duration(milliseconds: 500), () {
      if ( isConnected) {
        publishMessage(5, MQTTConfig.DeviceId, MQTTConfig.devicePassword);
      }
    });
    notifyListeners();

    subscribeToTopic(MQTTConfig.subscribeTopic);

    _client!.updates!.listen((List<MqttReceivedMessage<MqttMessage?>>? c) {
      if (c == null || c.isEmpty) return;
      final recMess = c[0].payload as MqttPublishMessage;
      final message = MqttPublishPayload.bytesToStringAsString(recMess.payload.message);
      _receivedMessage = message;

      print('📥 Nhận được: ${_formatJson(message)}');

      try {
        final jsonData = jsonDecode(message) as Map<String, dynamic>;
        if (jsonData.containsKey("method") && jsonData["method"] == "thing.event.property.post") {
          if (jsonData.containsKey("params")) {
            final params = jsonData["params"] as Map<String, dynamic>;
            if (params["DeviceID"] == int.parse(MQTTConfig.DeviceId)) {
              final messageId = jsonData["id"] as String;
              if (_lastCommandId != null && messageId == _lastCommandId) {
                print('🔔 Phản hồi khớp với lệnh ID: $messageId');
              }
              if (messageId == "60008") {
                _latestStatusMessage = jsonData;
                _deviceState = params["Status"] == 1;
                print('🔔 Cập nhật trạng thái thiết bị');
              } else if (messageId == "60009") {
                _latestFunctionMessage = jsonData;
                print('⚙️ Cập nhật cài đặt chức năng');
              } else if (messageId == "60002") {
                _latestSettingsMessage = jsonData;
                print('⚙️ Cập nhật cài đặt thiết bị');
              }
              notifyListeners();
            }
          }
        }
      } catch (e) {
        print('❌ Lỗi xử lý tin nhắn: $e');
      }
    });
  }

  void _onDisconnected() {
    if (_isConnected) {
      _isConnected = false;
      _connectionState = 'Đã ngắt kết nối';
      print('🔌 Mất kết nối MQTT');
      notifyListeners();
      _scheduleReconnect();
    }
  }

  void _onSubscribed(String topic) {
    print('📥 Đã đăng ký topic: $topic');
  }

  void _scheduleReconnect() {
    if (_reconnectAttempts >= _maxReconnectAttempts) {
      print('⚠️ Đã đạt tối đa số lần thử kết nối lại ($_maxReconnectAttempts)');
      _connectionState = 'Không thể kết nối sau $_maxReconnectAttempts lần thử';
      notifyListeners();
      return;
    }

    final delaySeconds = _baseReconnectDelaySeconds * pow(2, _reconnectAttempts).toInt();
    print('🔄 Thử kết nối lại sau $delaySeconds giây (lần thử ${_reconnectAttempts + 1})...');
    _reconnectAttempts++;

    Future.delayed(Duration(seconds: delaySeconds), () {
      if (!_isConnected) {
        connect();
      }
    });
  }

  void disconnect() {
    if (_client != null) {
      print('🔄 Đang ngắt kết nối MQTT...');
      _client!.disconnect();
      _client = null;
    }
    _isConnected = false;
    _connectionState = 'Đã ngắt kết nối';
    _receivedMessage = null;
    _latestStatusMessage = null;
    _latestFunctionMessage = null;
    _latestSettingsMessage = null;
    _lastCommandId = null;
    _lastCommandTime = null;
    _reconnectAttempts = 0;
    notifyListeners();
    print('✅ Đã ngắt kết nối MQTT thành công');
  }

  void subscribeToTopic(String topic) {
    if (_isConnected && _client != null) {
      print('📥 Đăng ký topic: $topic');
      _client!.subscribe(topic, MqttQos.atMostOnce);
    } else {
      print('⚠️ Không thể đăng ký topic: Chưa kết nối');
    }
  }

  void publishMessage(int action, String deviceId, String password) {
    if (!_isConnected || _client == null) {
      print('⚠️ Không thể gửi lệnh: Chưa kết nối hoặc client không tồn tại');
      _connectionState = 'Không thể gửi lệnh: Chưa kết nối';
      notifyListeners();
      return;
    }

    final payload = {
      "method": "thing.service.ControlDevice",
      "id": action == 7 ? "60008" : action == 12 ? "60009" : action == 5 ? "60002" : "63215998",
      "params": {
        "Action": action,
        "DeviceID": deviceId,
        "Password": password,
      },
      "version": MQTTConfig.version,
    };

    final builder = MqttClientPayloadBuilder();
    final jsonString = jsonEncode(payload);
    builder.addString(jsonString);

    print('📤 Đang gửi yêu cầu Action $action...');
    try {
      _client!.publishMessage(
        MQTTConfig.publishTopic,
        MqttQos.atMostOnce,
        builder.payload!,
        retain: false,
      );
      _lastCommandId = payload["id"] as String; // Sửa đổi của bạn
      _lastCommandTime = DateTime.now();
      print('📤 Gửi đi: ${_formatJson(jsonString)}');
    } catch (e) {
      print('❌ Lỗi gửi lệnh: $e');
      _connectionState = 'Lỗi gửi lệnh: $e';
      notifyListeners();
    }
  }

  bool? getDeviceStateFromMessage() {
    if (_receivedMessage == null) return null;
    try {
      final jsonData = jsonDecode(_receivedMessage!) as Map<String, dynamic>;
      if (jsonData.containsKey("params")) {
        final params = jsonData["params"] as Map<String, dynamic>;
        if (params["DeviceID"] == int.parse(MQTTConfig.DeviceId)) {
          return params["Status"] == 1;
        }
      }
    } catch (e) {
      print('❌ Lỗi phân tích tin nhắn: $e');
    }
    return null;
  }

  void refreshDeviceState() {
    print('🔄 Đang làm mới trạng thái thiết bị từ tin nhắn mới nhất...');
    final newState = getDeviceStateFromMessage();
    if (newState != null) {
      final oldState = _deviceState;
      _deviceState = newState;
      if (oldState != newState) {
        print('🔔 Trạng thái đã thay đổi từ ${oldState ? "BẬT ✅" : "TẮT ❌"} thành ${newState ? "BẬT ✅" : "TẮT ❌"}');
      } else {
        print('ℹ️ Trạng thái không thay đổi: ${newState ? "BẬT ✅" : "TẮT ❌"}');
      }
      notifyListeners();
    } else {
      print('⚠️ Không thể xác định trạng thái từ tin nhắn mới nhất');
    }
  }

  String _formatJson(String jsonString) {
    try {
      final dynamic parsedJson = jsonDecode(jsonString);
      return const JsonEncoder.withIndent('  ').convert(parsedJson);
    } catch (e) {
      return jsonString;
    }
  }

  void updateDeviceState(bool isOn) {
    print('🔄 Đang gửi lệnh ${isOn ? "BẬT" : "TẮT"} lúc ${DateTime.now()}...');
    publishMessage(isOn ? 1 : 0, MQTTConfig.DeviceId, MQTTConfig.devicePassword);
  }
}