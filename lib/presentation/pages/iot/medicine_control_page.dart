import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/models/medicine_model.dart';
import '../../../services/mqtt_manager.dart';
import '../../cubits/medicine_cubit.dart';

class MedicineControlPage extends StatefulWidget {
  const MedicineControlPage({super.key});

  @override
  State<MedicineControlPage> createState() => _MedicineControlPageState();
}

class _MedicineControlPageState extends State<MedicineControlPage> {
  final MqttManager _mqttManager = MqttManager();
  final Map<String, int> _selectedMedicines = {}; // {medicineId: quantity}
  bool _isPublishing = false;
  bool _isReconnecting = false;

  @override
  void initState() {
    super.initState();
    _connectMqtt();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MedicineCubit>().getMedicineList();
    });
  }

  Future<void> _connectMqtt() async {
    setState(() => _isReconnecting = true);
    await _mqttManager.connect();
    setState(() => _isReconnecting = false);
  }

  Future<void> _publish() async {
    if (_selectedMedicines.isEmpty) return;

    setState(() => _isPublishing = true);

    final connected = await _mqttManager.connect();
    if (connected) {
      final payload = <String, int>{};
      final state = context.read<MedicineCubit>().state;
      if (state is MedicineListLoaded) {
        for (var med in state.medicines) {
          if (_selectedMedicines[med.id] != null &&
              _selectedMedicines[med.id]! > 0 &&
              med.name != null) {
            payload[med.name!] = _selectedMedicines[med.id]!;
          }
        }
      }
      await _mqttManager.publishMedicineControl(payload);
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Đã gửi lệnh lên MQTT')));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('MQTT connection failed')));
    }

    setState(() => _isPublishing = false);
  }

  Future<void> _showAddMedicineDialog(List<MedicineModel> medicines) async {
    MedicineModel? selected;
    int quantity = 1;

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Thêm thuốc'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<MedicineModel>(
              items: medicines
                  .map((med) => DropdownMenuItem(
                        value: med,
                        child: Text(med.name ?? 'Thuốc ${med.id}'),
                      ))
                  .toList(),
              value: selected,
              onChanged: (val) {
                selected = val;
              },
              decoration: const InputDecoration(
                labelText: 'Chọn thuốc',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              initialValue: '1',
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                  labelText: 'Số lượng', border: OutlineInputBorder()),
              onChanged: (val) {
                quantity = int.tryParse(val) ?? 1;
              },
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          ElevatedButton(
              onPressed: () {
                if (selected != null && quantity > 0) {
                  setState(() {
                    _selectedMedicines[selected!.id] = quantity;
                  });
                  Navigator.pop(context);
                }
              },
              child: const Text('OK')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('MQTT Medicine Control')),
      body: BlocBuilder<MedicineCubit, MedicineState>(
        builder: (context, state) {
          if (state is MedicineLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is MedicineError) {
            return Center(child: Text(state.message));
          } else if (state is MedicineListLoaded) {
            final medicines = state.medicines;

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // List thuốc đã chọn
                  Expanded(
                    child: _selectedMedicines.isEmpty
                        ? const Center(child: Text('Chưa chọn thuốc nào'))
                        : ListView.builder(
                            itemCount: _selectedMedicines.length,
                            itemBuilder: (context, index) {
                              final id =
                                  _selectedMedicines.keys.elementAt(index);
                              final qty = _selectedMedicines[id]!;
                              final med =
                                  medicines.firstWhere((m) => m.id == id);
                              return Card(
                                child: ListTile(
                                  title: Text(med.name ?? 'Thuốc $id'),
                                  subtitle: Text('Số lượng: $qty'),
                                  trailing: IconButton(
                                    icon: const Icon(Icons.delete),
                                    onPressed: () {
                                      setState(() {
                                        _selectedMedicines.remove(id);
                                      });
                                    },
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                  const SizedBox(height: 12),

                  // Button thêm thuốc
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _showAddMedicineDialog(medicines),
                      icon: const Icon(Icons.add),
                      label: const Text('Thêm thuốc'),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Button gửi MQTT
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isPublishing ? null : _publish,
                      child: _isPublishing
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2),
                            )
                          : const Text('Gửi lệnh lên MQTT'),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Status & Reconnect
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        padding: const EdgeInsets.symmetric(
                            vertical: 6, horizontal: 16),
                        decoration: BoxDecoration(
                          color: _mqttManager.isConnected
                              ? Colors.green
                              : Colors.red,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          _mqttManager.isConnected
                              ? 'MQTT Connected'
                              : 'MQTT Disconnected',
                          style: const TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        onPressed: _mqttManager.isConnected || _isReconnecting
                            ? null
                            : _connectMqtt,
                        child: _isReconnecting
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text('Reconnect'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
