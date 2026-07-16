import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/alarm.dart';
import '../services/alarm_service.dart';
import 'alarm_ring_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final alarmService = Provider.of<AlarmService>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('QR Code Alarms'),
        actions: [
          // Simulated test button to easily trigger and experience the QR alarm flow
          IconButton(
            icon: const Icon(Icons.bolt, color: Colors.amber),
            tooltip: 'Simulate Alarm Now',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AlarmRingScreen(
                    targetQrValue: 'MUG_QR',
                    alarmLabel: 'Simulated Morning Coffee Alarm',
                  ),
                ),
              );
            },
          )
        ],
      ),
      body: alarmService.alarms.isEmpty
          ? const Center(
              child: Text(
                'No alarms set.\nTap + to create a QR-locked alarm.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: alarmService.alarms.length,
              itemBuilder: (context, index) {
                final alarm = alarmService.alarms[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  elevation: 4,
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    title: Text(
                      alarm.time,
                      style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(alarm.label, style: const TextStyle(fontWeight: FontWeight.w500)),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.qr_code, size: 14, color: Colors.amberAccent),
                            const SizedBox(width: 4),
                            Text(
                              'Dismiss key: "${alarm.qrValue}"',
                              style: const TextStyle(color: Colors.amberAccent, fontSize: 12),
                            ),
                          ],
                        ),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Switch(
                          value: alarm.isActive,
                          onChanged: (value) {
                            alarmService.toggleAlarm(alarm.id);
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.redAccent),
                          onPressed: () {
                            alarmService.deleteAlarm(alarm.id);
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddAlarmDialog(context, alarmService),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddAlarmDialog(BuildContext context, AlarmService service) {
    final timeController = TextEditingController(text: '08:00');
    final labelController = TextEditingController(text: 'Scan Bathroom Mirror');
    final qrController = TextEditingController(text: 'MIRROR_QR');

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('New QR Alarm'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: timeController,
                  decoration: const InputDecoration(
                    labelText: 'Alarm Time (HH:MM)',
                    icon: Icon(Icons.access_time),
                  ),
                ),
                TextField(
                  controller: labelController,
                  decoration: const InputDecoration(
                    labelText: 'Label',
                    icon: Icon(Icons.label),
                  ),
                ),
                TextField(
                  controller: qrController,
                  decoration: const InputDecoration(
                    labelText: 'Target QR Key Value',
                    helperText: 'You must scan a QR code with this text to turn off.',
                    icon: Icon(Icons.qr_code),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final newAlarm = Alarm(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  time: timeController.text,
                  label: labelController.text,
                  isActive: true,
                  qrValue: qrController.text,
                  days: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri'],
                );
                service.addAlarm(newAlarm);
                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }
}
