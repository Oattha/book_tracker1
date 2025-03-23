import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data; // ตรวจสอบการนำเข้าที่ถูกต้อง
import '../database/database_helper.dart';
import '../database/model.dart';

class CreateTaskScreen extends StatefulWidget {
  @override
  _CreateTaskScreenState createState() => _CreateTaskScreenState();
}

class _CreateTaskScreenState extends State<CreateTaskScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _dueDateController = TextEditingController();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  
  String? _imageUrl;

  @override
  void initState() {
    super.initState();
    _initializeNotifications(); // เรียกใช้เมื่อเริ่มต้น
  }

  Future<void> _initializeNotifications() async {
    tz_data.initializeTimeZones(); // เริ่มต้น timezone
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);
    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  Future<void> _scheduleNotification(Task2 task) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails('your_channel_name',
            'your_channel_description',
            importance: Importance.max,
            priority: Priority.high,
            showWhen: false);
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
    
    final dueDateTZ = tz.TZDateTime.from(task.dueDate, tz.local);

    await flutterLocalNotificationsPlugin.zonedSchedule(
      0,
      'Task Reminder',
      'Your task "${task.title}" is due soon!',
      dueDateTZ.subtract(Duration(minutes: 5)),
      platformChannelSpecifics,
      androidScheduleMode: AndroidScheduleMode.exact,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.dateAndTime,
    );
  }

  Future<void> _createTask(BuildContext context) async {
    String title = _titleController.text;
    String description = _descriptionController.text;
    DateTime dueDate = DateTime.parse(_dueDateController.text);

    if (title.isNotEmpty && description.isNotEmpty) {
      final databaseHelper = DatabaseHelper();
      
      _imageUrl = await databaseHelper.uploadImage();

      final task = Task2(
        title: title,
        description: description,
        dueDate: dueDate,
        imageUrl: _imageUrl,
      );

      FirebaseFirestore.instance.collection('tasks').add(task.toMap()).then((_) {
        _scheduleNotification(task);
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Task created successfully!')),
        );
        Navigator.pop(context);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create Task'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(labelText: 'Task Title'),
            ),
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(labelText: 'Description'),
            ),
            TextField(
              controller: _dueDateController,
              decoration: InputDecoration(labelText: 'Due Date (YYYY-MM-DD)'),
            ),
            SizedBox(height: 20),
            _imageUrl != null
                ? Image.network(_imageUrl!, height: 200)
                : SizedBox(height: 200, child: Placeholder()),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _createTask(context),
              child: Text('Create Task'),
            ),
          ],
        ),
      ),
    );
  }
}
