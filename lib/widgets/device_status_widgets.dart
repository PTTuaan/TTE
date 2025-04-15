import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

// DeviceFunctionWidget
class DeviceFunctionWidget extends StatelessWidget {
  final Map<String, dynamic> functionData;

  const DeviceFunctionWidget({super.key, required this.functionData});

  @override
  Widget build(BuildContext context) {
    final items = [
      {'label': 'Quá áp', 'value': functionData['Fuc_OverVoltage']},
      {'label': 'Thấp áp', 'value': functionData['Fuc_UnderVoltage']},
      {'label': 'Dòng rò', 'value': functionData['Fuc_Leakage']},
      {'label': 'Quá tải', 'value': functionData['Fuc_OverLoad']},
      {'label': 'Quá công suất', 'value': functionData['Fuc_HighPower']},
      {'label': 'Ngâm trong nước', 'value': functionData['Fuc_InWater']},
      {'label': 'Mất dây tiếp địa', 'value': functionData['Fuc_PE_OPEN']},
      {'label': 'Nhiệt độ cao', 'value': functionData['Fuc_TempHigh']},
      {'label': 'Cảnh báo trước', 'value': functionData['Alarm_Enable']},
      {'label': 'Nhảy chậm', 'value': functionData['TimeJump_Enable']},
      {'label': 'Cho phép cảnh báo', 'value': functionData['YJ_Enable']},
      {'label': 'Mất pha', 'value': functionData['Fuc_PhaseLoss']},
      {'label': 'Im lặng', 'value': functionData['Silent_Enable']},
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
                    'Các chức năng',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Chức năng',
                    style: TextStyle(
                      fontSize: 20,
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
              _buildFunctionRow(item['label']!, item['value']),
              if (index < items.length) const Divider(),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFunctionRow(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            _getStatusText(label, value),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: _getStatusColor(label, value),
            ),
          ),
        ],
      ),
    );
  }

  String _getStatusText(String label, dynamic value) {
    if (value == null) return "N/A";

    // Chức năng YES/NO: Nhảy chậm, Cho phép cảnh báo, Im lặng
    if (label == 'Nhảy chậm' || label == 'Cho phép cảnh báo' || label == 'Im lặng') {
      return value == 1 ? "YES" : "NO";
    }

    // Chức năng Dòng rò: Chỉ Alarm/Trip
    if (label == 'Dòng rò') {
      if (value == 1) return "Alarm";
      if (value == 2) return "Trip";
      return "N/A"; // Không có Shut
    }

    // Các chức năng còn lại: Alarm/Trip/Shut
    if (value == 1) return "Alarm";
    if (value == 2) return "Trip";
    if (value == 0) return "Shut";
    return "N/A";
  }

  Color _getStatusColor(String label, dynamic value) {
    if (value == null) return Colors.grey;

    // Chức năng YES/NO
    if (label == 'Nhảy chậm' || label == 'Cho phép cảnh báo' || label == 'Im lặng') {
      return value == 1 ? Colors.green : Colors.red;
    }

    // Chức năng Dòng rò
    if (label == 'Dòng rò') {
      if (value == 2) return Colors.green;
      if (value == 1) return Colors.orange;
      return Colors.grey; // Không có Shut
    }

    // Các chức năng còn lại
    if (value == 2) return Colors.green;
    if (value == 1) return Colors.orange;
    if (value == 0) return Colors.red;
    return Colors.grey;
  }
}
// DeviceSettingsWidget
class DeviceSettingsWidget extends StatelessWidget {
  final Map<String, dynamic> settingsData;

  const DeviceSettingsWidget({super.key, required this.settingsData});

  @override
  Widget build(BuildContext context) {
    final items = [
      {'label': 'Ngưỡng quá áp', 'value': settingsData['GY_Value'], 'unit': 'V'},
      {'label': 'Thời gian trễ quá áp', 'value': settingsData['GY_T'], 'unit': 's'},
      {'label': 'Ngưỡng thấp áp', 'value': settingsData['QY_Value'], 'unit': 'V'},
      {'label': 'Thời gian trễ thấp áp', 'value': settingsData['QY_T'], 'unit': 's'},
      {'label': 'Ngưỡng quá tải', 'value': settingsData['OverLoad_Value'], 'unit': 'A'},
      {'label': 'Thời gian trễ quá tải', 'value': settingsData['YS_OverLoad'], 'unit': 's'},
      {'label': 'Ngưỡng công suất cao', 'value': settingsData['HighPower_Value'], 'unit': 'W'},
      {'label': 'Thời gian trễ công suất cao', 'value': settingsData['YS_HighPower'], 'unit': 's'},
      {'label': 'Ngưỡng dòng rò', 'value': settingsData['LD_Value'], 'unit': 'mA'},
      {'label': 'Thời gian phát hiện ngập nước', 'value': settingsData['InWaterTime'], 'unit': 's'},
      {'label': 'Ngưỡng nhiệt độ cao', 'value': settingsData['WD_H_Value'], 'unit': '℃'},
      {'label': 'Thời gian trễ nhiệt độ', 'value': settingsData['YS_WD'], 'unit': 's'},
    ];

    return Padding(
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
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Cài đặt',
                    style: TextStyle(
                      fontSize: 20,
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
              _buildSettingRow(item['label']!, item['value'], item['unit']!),
              if (index < items.length) const Divider(),
            ],
          );
        },
      ),
    );
  }

 Widget _buildSettingRow(String label, dynamic value, String unit) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            value != null ? '$value $unit' : 'N/A',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}

// DeviceCardSelector
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