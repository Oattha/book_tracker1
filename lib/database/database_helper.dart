import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart'; // สำหรับการแจ้งเตือน
import 'package:image_picker/image_picker.dart'; // สำหรับการเลือกภาพ
import 'package:firebase_storage/firebase_storage.dart'; // สำหรับการอัปโหลดรูปภาพ
import 'model.dart'; // ทำการ import model ของ Task2
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;

class DatabaseHelper {
  final CollectionReference collection = FirebaseFirestore.instance.collection(Task2.collectionName);
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  final ImagePicker picker = ImagePicker(); // สำหรับการเลือกภาพ

  // Initialize timezone and notifications plugin
  DatabaseHelper() {
    tz_data.initializeTimeZones(); // ตั้งค่า timezones สำหรับการแจ้งเตือน
    _initializeNotifications();
  }

  Future<void> _initializeNotifications() async {
    var initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher'); // ไอคอนที่แสดงในแจ้งเตือน
    var initializationSettings = InitializationSettings(android: initializationSettingsAndroid);
    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  Future<void> insertTask(Task2 task) async {
    var docRef = await collection.add(task.toMap());
    task.referenceId = docRef.id; // เซ็ต referenceId หลังจากเพิ่มลง Firebase แล้ว
    await scheduleNotification(task); // เรียกการตั้งค่าแจ้งเตือนเมื่อเพิ่มงานใหม่
  }

  Future<void> updateTask(Task2 task) async {
    if (task.referenceId != null) {
      await collection.doc(task.referenceId).update(task.toMap());
      await scheduleNotification(task); // อัปเดตการแจ้งเตือนเมื่อแก้ไขงาน
    } else {
      throw Exception('Task referenceId is null');
    }
  }

  Future<void> deleteTask(Task2 task) async {
    if (task.referenceId != null) {
      await flutterLocalNotificationsPlugin.cancel(task.hashCode); // ยกเลิกการแจ้งเตือนก่อนลบงาน
      await collection.doc(task.referenceId).delete();
    } else {
      throw Exception('Task referenceId is null');
    }
  }

  Future<void> deleteTaskById(String referenceId) async {
    if (referenceId.isNotEmpty) {
      await flutterLocalNotificationsPlugin.cancel(referenceId.hashCode); // ยกเลิกการแจ้งเตือนก่อนลบงาน
      await collection.doc(referenceId).delete();
    } else {
      throw Exception('Reference ID is empty');
    }
  }

  Stream<QuerySnapshot> getStream() {
    return collection.snapshots();
  }

  Future<List<Task2>> getTasks() async {
    QuerySnapshot querySnapshot = await collection.get();
    return querySnapshot.docs.map((doc) {
      return Task2.fromMap(doc.data() as Map<String, dynamic>, doc.id); // แก้ไขตรงนี้
    }).toList();
  }

  // ฟังก์ชันสำหรับการอัปโหลดรูปภาพ
Future<String?> uploadImage() async {
  try {
    // เลือกไฟล์รูปภาพ
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile == null) return null; // ถ้าไม่ได้เลือกไฟล์

    // โหลดไฟล์เข้าสู่ Firebase Storage
    final File file = File(pickedFile.path);
    final storageRef = FirebaseStorage.instance.ref().child('images/${DateTime.now().millisecondsSinceEpoch}.png');
    
    TaskSnapshot task = await storageRef.putFile(file);

    // รับ URL ของรูปภาพที่อัปโหลด
    String downloadUrl = await task.ref.getDownloadURL();
    return downloadUrl; // คืนค่า URL ของรูปที่อัปโหลดสำเร็จ
  } catch (e) {
    print('Error during file upload: $e');
    return null;
  }
}


  // เพิ่มฟังก์ชันตั้งค่าการแจ้งเตือน
  Future<void> scheduleNotification(Task2 task) async {
    if (task.dueDate.isBefore(DateTime.now())) {
      return; // ถ้าวันที่ส่งงานหมดแล้วไม่ต้องแจ้งเตือน
    }

    var androidDetails = AndroidNotificationDetails(
      'task_channel_id',
      'Task Notifications This channel is for task deadline notifications',
      importance: Importance.max,
      priority: Priority.high,
    );

    var platformDetails = NotificationDetails(android: androidDetails);

    // ตั้งเวลาแจ้งเตือนก่อน 30 นาที
    var scheduledTime = tz.TZDateTime.from(task.dueDate.subtract(Duration(minutes: 30)), tz.local);

    await flutterLocalNotificationsPlugin.zonedSchedule(
      task.hashCode,
      'Task Reminder',
      'Task "${task.title}" is due soon!',
      scheduledTime,
      platformDetails,
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.wallClockTime,
      matchDateTimeComponents: DateTimeComponents.time, // เพื่อให้แจ้งเตือนตรงเวลา
    );
  }
}
