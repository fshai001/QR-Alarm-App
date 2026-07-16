import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'qr_scanner_page.dart';

class AlarmRingScreen extends StatefulWidget {
  final String targetQrValue;
  final String alarmLabel;

  const AlarmRingScreen({
    super.key,
    required this.targetQrValue,
    required this.alarmLabel,
  });

  @override
  State<AlarmRingScreen> createState() => _AlarmRingScreenState();
}

class _AlarmRingScreenState extends State<AlarmRingScreen> {
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    // 1. Play wake-up alarm sound in an infinite loop
    _audioPlayer.setReleaseMode(ReleaseMode.loop);
    _audioPlayer.setVolume(1.0);
    _audioPlayer.play(AssetSource('alarm_sound.mp3'));
  }

  @override
  void dispose() {
    // 2. Safely halt sound once screen is dismissed
    _audioPlayer.stop();
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // WillPopScope prevents user from using the physical back button to easily close the alarm
    return WillPopScope(
      onWillPop: () async => false, // Return false to disable hardware back button dismissal
      child: Scaffold(
        backgroundColor: Colors.black87,
        body: SafeArea(
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Vibrating Alarm Ring Animation
                Column(
                  children: [
                    const Icon(
                      Icons.alarm_on,
                      size: 96,
                      color: Colors.redAccent,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      widget.alarmLabel.toUpperCase(),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),

                // Prompt detailing task
                Card(
                  color: Colors.red.withOpacity(0.15),
                  shape: RoundedRectangleBorder(
                    side: const BorderSide(color: Colors.redAccent, width: 2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        const Text(
                          'DISMISSAL CONDITION ACTIVE',
                          style: TextStyle(
                            color: Colors.redAccent,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'You must scan the QR code containing:\n"${widget.targetQrValue}"\nto turn off this alarm.',
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 15, color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                ),

                // Button that opens the camera QR scanner
                ElevatedButton.icon(
                  onPressed: () async {
                    // Navigate to camera scanner and await verification result
                    final bool? isDismissed = await Navigator.push<bool>(
                      context,
                      MaterialPageRoute(
                        builder: (context) => QRScannerPage(targetQrValue: widget.targetQrValue),
                      ),
                    );

                    if (isDismissed == true) {
                      // Stop sound and close this ringing screen
                      if (mounted) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Alarm dismissed! Good morning!'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      }
                    }
                  },
                  icon: const Icon(Icons.camera_alt),
                  label: const Text('OPEN CAMERA & SCAN QR'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
                    textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
