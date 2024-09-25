import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:async';

void main() {
  runApp(ReminderApp());
}

class ReminderApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Reminder App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: ReminderScreen(),
    );
  }
}

class ReminderScreen extends StatefulWidget {
  @override
  _ReminderScreenState createState() => _ReminderScreenState();
}

class _ReminderScreenState extends State<ReminderScreen> {
  String? selectedDay;
  TimeOfDay? selectedTime;
  String? selectedActivity;

  AudioPlayer audioPlayer = AudioPlayer();

  final List<String> daysOfWeek = [
    'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'
  ];

  final List<String> activities = [
    'Wake up', 'Go to Gym', 'Breakfast', 'Meetings', 
    'Lunch', 'Quick nap', 'Go to library', 'Dinner', 'Go to sleep'
  ];

  Timer? _timer;

  void _scheduleReminder() {
    if (selectedDay != null && selectedTime != null && selectedActivity != null) {
      final now = DateTime.now();
      final selectedDateTime = DateTime(now.year, now.month, now.day, selectedTime!.hour, selectedTime!.minute);
      final difference = selectedDateTime.difference(now).inSeconds;

      if (difference > 0) {
        _timer = Timer(Duration(seconds: difference), _playChime);
      }
    }
  }

  void _playChime() async {
    await audioPlayer.play(AssetSource('wind-chime-70690.mp3')); // Add your chime.mp3 file in assets folder
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('It\'s time for $selectedActivity!')),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null && picked != selectedTime) {
      setState(() {
        selectedTime = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Daily Reminder'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DropdownButtonFormField<String>(
              value: selectedDay,
              hint: Text('Select Day of the Week'),
              onChanged: (String? newValue) {
                setState(() {
                  selectedDay = newValue;
                });
              },
              items: daysOfWeek.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            SizedBox(height: 20),
            Row(
              children: [
                Text('Select Time:'),
                SizedBox(width: 10),
                TextButton(
                  onPressed: () => _selectTime(context),
                  child: Text(selectedTime == null
                      ? 'Choose Time'
                      : selectedTime!.format(context)),
                ),
              ],
            ),
            SizedBox(height: 20),
            DropdownButtonFormField<String>(
              value: selectedActivity,
              hint: Text('Select Activity'),
              onChanged: (String? newValue) {
                setState(() {
                  selectedActivity = newValue;
                });
              },
              items: activities.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            SizedBox(height: 30),
            Center(
              child: ElevatedButton(
                onPressed: _scheduleReminder,
                child: Text('Set Reminder'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
