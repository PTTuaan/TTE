import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:provider/provider.dart';
import 'package:tte/mqtt_app_state.dart' as mqttState;
import 'package:tte/mqtt_app_state.dart';
import 'package:tte/mqtt_config.dart';

// DeviceStatusWidget
class DeviceStatusWidget extends StatelessWidget {
  final Map<String, dynamic> statusData;

  const DeviceStatusWidget({super.key, required this.statusData});

  @override
  Widget build(BuildContext context) {
  final items = [
      {'label': 'Điện áp', 'value': '${statusData['Real_UA']?.toString() ?? '0'} V'},
      {'label': 'Dòng điện', 'value': '${statusData['Real_IA']?.toString() ?? '0'} A'},
      {'label': 'Nhiệt độ', 'value': '${statusData['Real_TA']?.toString() ?? '0'} ℃'},
      {'label': 'Nhiệt độ dây N', 'value': '${statusData['Real_TN']?.toString() ?? '0'} ℃'},
      {'label': 'Dòng rò', 'value': '${statusData['Real_LD']?.toString() ?? '0'} mA'},
      {'label': 'Công suất tác dụng', 'value': '${(((statusData['YGGL_P'] as num?) ?? 0) * 1000).toString()} W'},
      {'label': 'Công suất phản kháng', 'value': '${(((statusData['WGGL_Q'] as num?) ?? 0) * 1000).toString()} VAR'},
      {'label': 'Công suất biểu kiến', 'value': '${(((statusData['SZGL_S'] as num?) ?? 0) * 1000).toString()} VA'},
      {'label': 'Công suất tác dụng pha A', 'value': '${(((statusData['YGGL_PA'] as num?) ?? 0 )* 1000).toString()} W'},
      {'label': 'Công suất phản kháng pha A', 'value': '${(((statusData['WGGL_QA'] as num?) ?? 0) * 1000).toString()} VAR'},
      {'label': 'Công suất biểu kiến pha A', 'value': '${(((statusData['SZGL_SA'] as num?) ?? 0 )* 1000).toString()} VA'},
      {'label': 'Năng lượng tiêu thụ', 'value': '${statusData['ActiveEnergyImport']?.toString() ?? '0'} kWh'},
      {'label': 'Năng lượng tiêu thụ pha L1', 'value': '${statusData['ActiveEnergyImportInPhaseL1']?.toString() ?? '0'} kWh'},
      {'label': 'Tần số', 'value': '${statusData['electric_fr']?.toString() ?? '0'} Hz'},
    ];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: items.length + 1, // +1 cho tiêu đề
        itemBuilder: (context, index) {
          if (index == 0) {
            return const Padding(
              padding: EdgeInsets.only(bottom: 10, top: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Thông số thiết bị',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Thông số',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            );
          }
          final item = items[index - 1];
          return Column(
            children: [
              _buildStatusRow(item['label']!, item['value']!),
              if (index < items.length) const Divider(),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStatusRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 15,
              color: Colors.black,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
// DeviceFunctionWidget
class DeviceFunctionWidget extends StatefulWidget {
  final Map<String, dynamic> functionData;

  const DeviceFunctionWidget({super.key, required this.functionData});

  @override
  _DeviceFunctionWidgetState createState() => _DeviceFunctionWidgetState();
}

class _DeviceFunctionWidgetState extends State<DeviceFunctionWidget> {
  late Map<String, dynamic> _tempFunctions;

  @override
  void initState() {
    super.initState();
    _tempFunctions = Map<String, dynamic>.from(widget.functionData);
  }

  void _updateFunction(String key, dynamic value) {
    setState(() {
      _tempFunctions[key] = value;
    });
  }

  void _submitFunctions() {
    final mqttAppState = Provider.of<mqttState.MQTTAppState>(context, listen: false);
    final payload = {
      "method": "thing.service.property.set",
      "id": "60009",
      "params": {
        "DeviceID": int.parse(MQTTConfig.DeviceId),
        "DeviceType": 20,
        "Fuc_OverVoltage": _tempFunctions['Fuc_OverVoltage'] ?? 1,
        "Fuc_UnderVoltage": _tempFunctions['Fuc_UnderVoltage'] ?? 1,
        "Fuc_OverLoad": _tempFunctions['Fuc_OverLoad'] ?? 2,
        "AutoClose_Enable": _tempFunctions['AutoClose_Enable'] ?? 0,
        "Fuc_UnderLoad": _tempFunctions['Fuc_UnderLoad'] ?? 0,
        "Fuc_HighPower": _tempFunctions['Fuc_HighPower'] ?? 1,
        "Fuc_LowPower": _tempFunctions['Fuc_LowPower'] ?? 0,
        "YJ_Enable": _tempFunctions['YJ_Enable'] ?? 0,
        "TimeJump_Enable": _tempFunctions['TimeJump_Enable'] ?? 0,
        "Alarm_Enable": _tempFunctions['Alarm_Enable'] ?? 1,
        "TimerControl_Enable": _tempFunctions['TimerControl_Enable'] ?? 0,
        "Fuc_Leakage": _tempFunctions['Fuc_Leakage'] ?? 2,
        "LD_TB_Enable": _tempFunctions['LD_TB_Enable'] ?? 0,
        "LevelBack_Enable": _tempFunctions['LevelBack_Enable'] ?? 0,
        "Fuc_InWater": _tempFunctions['Fuc_InWater'] ?? 1,
        "Fuc_PE_OPEN": _tempFunctions['Fuc_PE_OPEN'] ?? 1,
        "Fuc_TempHigh": _tempFunctions['Fuc_TempHigh'] ?? 1,
      },
      "version": "20_HD460_4P20.15",
    };

    mqttAppState.publishMessageCustom(payload);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Đã gửi cài đặt chức năng mới')),
    );
  }

  void _showStatusPicker(BuildContext context, String label, String key, dynamic currentValue) {
    List<Map<String, dynamic>> statuses;
    if (label == 'Nhảy chậm' || 
        label == 'Cho phép cảnh báo' || 
        label == 'Tự đóng' || 
        label == 'Cảnh báo trước' || 
        label == 'Điều khiển thời gian' || 
        label == 'Bảo vệ dòng rò' || 
        label == 'Quay lại cấp độ') {
      statuses = [
        {'text': 'YES', 'value': 1},
        {'text': 'NO', 'value': 0},
      ];
    } else if (label == 'Dòng rò') {
      statuses = [
        {'text': 'Alarm', 'value': 1},
        {'text': 'Trip', 'value': 2},
      ];
    } else {
      statuses = [
        {'text': 'Alarm', 'value': 1},
        {'text': 'Trip', 'value': 2},
        {'text': 'Shut', 'value': 0},
      ];
    }

    int initialIndex = statuses.indexWhere((s) => s['value'] == currentValue);
    if (initialIndex == -1) initialIndex = 0;
    int selectedIndex = initialIndex;

    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Container(
              height: 300,
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Text(
                    'Chọn trạng thái cho $label',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: CupertinoPicker(
                      itemExtent: 40.0,
                      scrollController: FixedExtentScrollController(initialItem: initialIndex),
                      onSelectedItemChanged: (int index) {
                        setModalState(() {
                          selectedIndex = index;
                        });
                      },
                      children: statuses.map((status) {
                        return Center(
                          child: Text(
                            status['text'],
                            style: const TextStyle(fontSize: 20),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          _updateFunction(key, statuses[selectedIndex]['value']);
                          _submitFunctions();
                          Navigator.pop(context);
                        },
                        child: const Text('Xác nhận'),
                      ),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Hủy'),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final items = [
      {'label': 'Quá áp', 'key': 'Fuc_OverVoltage'},
      {'label': 'Thấp áp', 'key': 'Fuc_UnderVoltage'},
      {'label': 'Dòng rò', 'key': 'Fuc_Leakage'},
      {'label': 'Quá tải', 'key': 'Fuc_OverLoad'},
      {'label': 'Quá công suất', 'key': 'Fuc_HighPower'},
      {'label': 'Ngâm trong nước', 'key': 'Fuc_InWater'},
      {'label': 'Mất dây tiếp địa', 'key': 'Fuc_PE_OPEN'},
      {'label': 'Nhiệt độ cao', 'key': 'Fuc_TempHigh'},
      {'label': 'Cảnh báo trước', 'key': 'Alarm_Enable'},
      {'label': 'Nhảy chậm', 'key': 'TimeJump_Enable'},
      {'label': 'Cho phép cảnh báo', 'key': 'YJ_Enable'},
      {'label': 'Thấp tải', 'key': 'Fuc_UnderLoad'},
      {'label': 'Thấp công suất', 'key': 'Fuc_LowPower'},
      {'label': 'Tự đóng', 'key': 'AutoClose_Enable'},
      {'label': 'Điều khiển thời gian', 'key': 'TimerControl_Enable'},
      {'label': 'Bảo vệ dòng rò', 'key': 'LD_TB_Enable'},
      {'label': 'Quay lại cấp độ', 'key': 'LevelBack_Enable'},
    ];

    return Column(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: items.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return const Padding(
                    padding: EdgeInsets.only(bottom: 10, top: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Các chức năng',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Trạng thái',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  );
                }
                final item = items[index - 1];
                return Column(
                  children: [
                    _buildFunctionRow(item['label']!, item['key']!, _tempFunctions[item['key']!]),
                    if (index < items.length) const Divider(),
                  ],
                );
              },
            ),
          ),
        ),
        // Padding(
        //   padding: const EdgeInsets.all(8.0),
        //   child: ElevatedButton(
        //     onPressed: _submitFunctions,
        //     style: ElevatedButton.styleFrom(
        //       minimumSize: const Size.fromHeight(50),
        //       backgroundColor: Colors.blue,
        //     ),
        //     child: const Text('Lưu cài đặt', style: TextStyle(color: Colors.white, fontSize: 18)),
        //   ),
        // ),
      ],
    );
  }

  Widget _buildFunctionRow(String label, String key, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 15,
                color: Colors.black,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          GestureDetector(
            onTap: () {
              _showStatusPicker(context, label, key, value);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
              child: Text(
                _getStatusText(label, value),
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: _getStatusColor(label, value),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getStatusText(String label, dynamic value) {
    if (value == null) return "N/A";

    if (label == 'Nhảy chậm' || 
        label == 'Cho phép cảnh báo' || 
        label == 'Tự đóng' || 
        label == 'Cảnh báo trước' || 
        label == 'Điều khiển thời gian' || 
        label == 'Bảo vệ dòng rò' || 
        label == 'Quay lại cấp độ') {
      return value == 1 ? "YES" : "NO";
    }

    if (label == 'Dòng rò') {
      if (value == 1) return "Alarm";
      if (value == 2) return "Trip";
      return "N/A";
    }

    if (value == 1) return "Alarm";
    if (value == 2) return "Trip";
    if (value == 0) return "Shut";
    return "N/A";
  }

  Color _getStatusColor(String label, dynamic value) {
    if (value == null) return Colors.grey;

    if (label == 'Nhảy chậm' || 
        label == 'Cho phép cảnh báo' || 
        label == 'Tự đóng' || 
        label == 'Cảnh báo trước' || 
        label == 'Điều khiển thời gian' || 
        label == 'Bảo vệ dòng rò' || 
        label == 'Quay lại cấp độ') {
      return value == 1 ? Colors.green : Colors.red;
    }

    if (label == 'Dòng rò') {
      if (value == 2) return Colors.green;
      if (value == 1) return Colors.orange;
      return Colors.grey;
    }

    if (value == 2) return Colors.green;
    if (value == 1) return Colors.orange;
    if (value == 0) return Colors.red;
    return Colors.grey;
  }
}
// DeviceSettingsWidget
class DeviceSettingsWidget extends StatefulWidget {
  final Map<String, dynamic> settingsData;

  const DeviceSettingsWidget({super.key, required this.settingsData});

  @override
  _DeviceSettingsWidgetState createState() => _DeviceSettingsWidgetState();
}

// DeviceSettingsWidget (chỉ hiển thị các phần thay đổi)
class _DeviceSettingsWidgetState extends State<DeviceSettingsWidget> {
  late Map<String, dynamic> _tempSettings;

  @override
  void initState() {
    super.initState();
    _tempSettings = Map<String, dynamic>.from(widget.settingsData);
  }

  void _updateSetting(String key, dynamic value) {
    setState(() {
      _tempSettings[key] = value;
    });
  }

  void _submitSettings() {
    final mqttAppState = Provider.of<mqttState.MQTTAppState>(context, listen: false);
    final payload = {
      "method": "thing.service.property.set",
      "id": "60002",
      "params": {
        "DeviceID": int.parse(MQTTConfig.DeviceId),
        "DeviceType": 20,
        "Position": "B0ECB9ABCAD2",
        "GY_Value": _tempSettings['GY_Value'] ?? 275,
        "GY_T": _tempSettings['GY_T'] ?? 1,
        "QY_Value": _tempSettings['QY_Value'] ?? 165,
        "QY_T": _tempSettings['QY_T'] ?? 3,
        "OverLoad_Value": _tempSettings['OverLoad_Value'] ?? 63,
        "YS_OverLoad": _tempSettings['YS_OverLoad'] ?? 3,
        "WD_H_Value": _tempSettings['WD_H_Value'] ?? 75,
        "YS_WD": _tempSettings['YS_WD'] ?? 5,
        "YJ_Per": _tempSettings['YJ_Per'] ?? 95,
        "UnderLoad_Per": _tempSettings['UnderLoad_Per'] ?? 5,
        "YS_UnderLoad": _tempSettings['YS_UnderLoad'] ?? 5,
        "LowPower_Value": _tempSettings['LowPower_Value'] ?? 5,
        "YS_LowPower": _tempSettings['YS_LowPower'] ?? 5,
        "HighPower_Value": _tempSettings['HighPower_Value'] ?? 15000,
        "YS_Reset": _tempSettings['YS_Reset'] ?? 5,
        "LD_Value": _tempSettings['LD_Value'] ?? 30,
        "LD_NowSet": _tempSettings['LD_NowSet'] ?? 30,
        "LD_T": _tempSettings['LD_T'] ?? 0,
        "LD_LockCount": _tempSettings['LD_LockCount'] ?? 0,
        "LD_TB_Value": _tempSettings['LD_TB_Value'] ?? 30,
        "mTryJumpTime_DD": _tempSettings['mTryJumpTime_DD'] ?? 20,
        "mTryJumpTime_HH": _tempSettings['mTryJumpTime_HH'] ?? 23,
        "mTryJumpTime_NN": _tempSettings['mTryJumpTime_NN'] ?? 30,
        "Password": MQTTConfig.devicePassword,
        "InWaterTime": _tempSettings['InWaterTime'] ?? 10,
        "YS_HighPower": _tempSettings['YS_HighPower'] ?? 5,
      },
      "version": MQTTConfig.version,
    };

    mqttAppState.publishMessageCustom(payload);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Đã gửi cài đặt mới')),
    );
  }

  void _showValuePicker(BuildContext context, String key, num currentValue, num min, num max, num step, String unit, {List<int>? fixedValues}) {
    List<int> values;
    int initialIndex;
    int selectedIndex;

    if (fixedValues != null && fixedValues.isNotEmpty) {
      // Sử dụng fixedValues cho LD_Value
      values = fixedValues;
      initialIndex = values.indexOf(currentValue.toInt());
      if (initialIndex == -1) initialIndex = 0;
    } else {
      // Sử dụng min, max, step cho các mục khác
      int minValue = min.toInt();
      int maxValue = max.toInt();
      int stepValue = step.toInt().clamp(1, (maxValue - minValue).abs());
      values = [];
      for (int i = minValue; i <= maxValue; i += stepValue) {
        values.add(i);
      }
      initialIndex = values.indexOf((currentValue.clamp(minValue, maxValue) as num).toInt());
      if (initialIndex == -1) initialIndex = 0;
    }

    selectedIndex = initialIndex;

    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Container(
              height: 300,
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Text(
                    'Chọn giá trị $unit',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: CupertinoPicker(
                      itemExtent: 40.0,
                      scrollController: FixedExtentScrollController(initialItem: initialIndex),
                      onSelectedItemChanged: (int index) {
                        setModalState(() {
                          selectedIndex = index;
                        });
                      },
                      children: values.map((value) {
                        return Center(
                          child: Text(
                            '$value',
                            style: const TextStyle(fontSize: 20),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          _updateSetting(key, values[selectedIndex]);
                          _submitSettings();
                          Navigator.pop(context);
                        },
                        child: const Text('Xác nhận'),
                      ),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Hủy'),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSettingRow(String label, String key, dynamic value, String unit, num step, num min, num max, {List<int>? fixedValues}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 15,
                color: Colors.black,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          GestureDetector(
            onTap: () {
              _showValuePicker(context, key, value ?? (fixedValues?.first ?? min), min, max, step, unit, fixedValues: fixedValues);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
              child: Text(
                value != null ? '$value $unit' : 'N/A',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> items = [
      <String, dynamic>{'label': 'Ngưỡng quá áp', 'key': 'GY_Value', 'unit': 'V', 'step': 1, 'min': 250, 'max': 350},
      <String, dynamic>{'label': 'Thời gian trễ quá áp', 'key': 'GY_T', 'unit': 's', 'step': 1, 'min': 0, 'max': 10},
      <String, dynamic>{'label': 'Ngưỡng thấp áp', 'key': 'QY_Value', 'unit': 'V', 'step': 1, 'min': 110, 'max': 200},
      <String, dynamic>{'label': 'Thời gian trễ thấp áp', 'key': 'QY_T', 'unit': 's', 'step': 1, 'min': 1, 'max': 10},
      <String, dynamic>{'label': 'Ngưỡng quá tải', 'key': 'OverLoad_Value', 'unit': 'A', 'step': 1, 'min': 10, 'max': 63},
      <String, dynamic>{'label': 'Thời gian trễ quá tải', 'key': 'YS_OverLoad', 'unit': 's', 'step': 1, 'min': 3, 'max': 18},
      <String, dynamic>{'label': 'Ngưỡng công suất cao', 'key': 'HighPower_Value', 'unit': 'W', 'step': 100, 'min': 1000, 'max': 20000},
      <String, dynamic>{'label': 'Thời gian trễ công suất cao', 'key': 'YS_HighPower', 'unit': 's', 'step': 1, 'min': 0, 'max': 10},
      <String, dynamic>{'label': 'Ngưỡng dòng rò', 'key': 'LD_Value', 'unit': 'mA', 'fixedValues': [30, 50, 100, 300, 500]},
      <String, dynamic>{'label': 'Thời gian phát hiện ngập nước', 'key': 'InWaterTime', 'unit': 's', 'step': 1, 'min': 10, 'max': 600},
      <String, dynamic>{'label': 'Ngưỡng nhiệt độ cao', 'key': 'WD_H_Value', 'unit': '℃', 'step': 1, 'min': 60, 'max': 100},
      <String, dynamic>{'label': 'Thời gian trễ nhiệt độ', 'key': 'YS_WD', 'unit': 's', 'step': 1, 'min': 1, 'max': 10},
    ];

    return Column(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: items.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return const Padding(
                    padding: EdgeInsets.only(bottom: 10, top: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Cài đặt',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Giá trị',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  );
                }
                final item = items[index - 1];
                return Column(
                  children: [
                    _buildSettingRow(
                      item['label'] as String,
                      item['key'] as String,
                      _tempSettings[item['key']!],
                      item['unit'] as String,
                      item['step'] as num? ?? 1,
                      item['min'] as num? ?? 0,
                      item['max'] as num? ?? 0,
                      fixedValues: item['fixedValues'] as List<int>?,
                    ),
                    if (index < items.length) const Divider(),
                  ],
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

class DeviceCardSelector extends StatefulWidget {
  const DeviceCardSelector({super.key});

  @override
  State<DeviceCardSelector> createState() => _DeviceCardSelectorState();
}

class _DeviceCardSelectorState extends State<DeviceCardSelector> with SingleTickerProviderStateMixin {
  TabController? _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mqttAppState = Provider.of<MQTTAppState>(context);

    if (_tabController == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TabBar(
          controller: _tabController,
          labelColor: Colors.grey[700],
          unselectedLabelColor: Colors.grey[700],
          indicator: const UnderlineTabIndicator(
            borderSide: BorderSide(
              color: Colors.green,
              width: 2.0,
            ),
            insets: EdgeInsets.symmetric(horizontal: 16.0),
          ),
          labelStyle: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
          tabs: const [
            Tab(text: "Trạng thái"),
            Tab(text: "Chức năng"),
            Tab(text: "Cài đặt"),
          ],
        ),
        const SizedBox(height: 10),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            physics: const ClampingScrollPhysics(),
            children: [
              DeviceStatusWidget(
                statusData: mqttAppState.latestStatusMessage?['params'] ?? {},
              ),
              DeviceFunctionWidget(
                functionData: mqttAppState.latestFunctionMessage?['params'] ?? {},
              ),
              DeviceSettingsWidget(
                settingsData: mqttAppState.latestSettingsMessage?['params'] ?? {},
              ),
            ],
          ),
        ),
      ],
    );
  }
}