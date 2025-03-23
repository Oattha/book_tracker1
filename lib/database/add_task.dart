import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../database/model.dart';

class AddTaskPage extends StatefulWidget {
  final DatabaseHelper dbHelper;

  const AddTaskPage({Key? key, required this.dbHelper}) : super(key: key);

  @override
  _AddTaskPageState createState() => _AddTaskPageState();
}

class _AddTaskPageState extends State<AddTaskPage> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  String _title = '';
  String _description = '';
  DateTime _dueDate = DateTime.now();
  int _progress = 0;
  TimeOfDay _dueTime = TimeOfDay.now(); // ตัวแปรสำหรับเวลา
  String? _imageUrl; // ตัวแปรสำหรับเก็บ URL ของภาพ

  late AnimationController _controller;
  late Animation<Color?> _colorAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 5),
      vsync: this,
    )..repeat(reverse: true); // ทำให้การเคลื่อนไหวเกิดขึ้นเรื่อยๆ

    _colorAnimation = ColorTween(
      begin: Colors.pinkAccent.withOpacity(0.5),
      end: Colors.lightBlueAccent.withOpacity(0.5),
    ).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose(); // ไม่ลืม dispose controller
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('เพิ่มงานใหม่'),
      ),
      body: AnimatedBuilder(
        animation: _colorAnimation,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  _colorAnimation.value!,
                  Colors.white.withOpacity(0.5),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      decoration: const InputDecoration(labelText: 'ชื่องาน'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'กรุณากรอกชื่องาน';
                        }
                        return null;
                      },
                      onChanged: (value) {
                        _title = value;
                      },
                    ),
                    TextFormField(
                      decoration: const InputDecoration(labelText: 'รายละเอียด'),
                      onChanged: (value) {
                        _description = value;
                      },
                    ),
                    TextFormField(
                      decoration: const InputDecoration(labelText: 'วันที่กำหนดส่ง'),
                      onTap: () async {
                        FocusScope.of(context).requestFocus(FocusNode());
                        DateTime? pickedDate = await showDatePicker(
                          context: context,
                          initialDate: _dueDate,
                          firstDate: DateTime.now(),
                          lastDate: DateTime(2101),
                        );
                        if (pickedDate != null) {
                          setState(() {
                            _dueDate = pickedDate;
                          });
                        }
                      },
                      readOnly: true,
                      controller: TextEditingController(
                        text: "${_dueDate.toLocal().toString().split(' ')[0]} "
                        "${_dueTime.hour}:${_dueTime.minute.toString().padLeft(2, '0')}", // แสดงวันที่และเวลา
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        TimeOfDay? pickedTime = await showTimePicker(
                          context: context,
                          initialTime: _dueTime,
                        );
                        if (pickedTime != null) {
                          setState(() {
                            _dueTime = pickedTime;
                          });
                        }
                      },
                      child: const Text('เลือกเวลา'),
                    ),
                    // แสดงข้อความ "ความคืบหน้า"
                    Text('ความคืบหน้า: $_progress%', style: TextStyle(fontSize: 16)), // ข้อความแสดงความคืบหน้า
                    Slider(
                      value: _progress.toDouble(),
                      min: 0,
                      max: 100,
                      divisions: 100,
                      label: _progress.toString(),
                      onChanged: (value) {
                        setState(() {
                          _progress = value.toInt();
                        });
                      },
                    ),
                    // เพิ่มปุ่มสำหรับอัปโหลดรูปภาพ
                    ElevatedButton(
                      onPressed: () async {
                        try {
                          String? imageUrl = await widget.dbHelper.uploadImage();
                          if (imageUrl != null && imageUrl.isNotEmpty) { // ตรวจสอบว่ามี URL หรือไม่
                            setState(() {
                              _imageUrl = imageUrl; // เก็บ URL ของภาพที่อัปโหลด
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('อัปโหลดรูปภาพสำเร็จ!')),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('การอัปโหลดไม่สำเร็จ!Something went wrong แงงง')),
                            );
                          }
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('เกิดข้อผิดพลาดในการอัปโหลดรูปภาพ Something went wrong แงงง: $e')),
                          );
                        }
                      },
                      child: const Text('อัปโหลดรูปภาพ'),
                    ),
                    // แสดง URL ของภาพที่อัปโหลด
                    if (_imageUrl != null) Text('รูปภาพที่อัปโหลด: $_imageUrl'),
                    ElevatedButton(
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          // บันทึกงานใหม่
                          var newTask = Task2(
                            title: _title,
                            description: _description,
                            dueDate: DateTime(
                              _dueDate.year,
                              _dueDate.month,
                              _dueDate.day,
                              _dueTime.hour,
                              _dueTime.minute,
                            ),
                            progress: _progress,
                            imageUrl: _imageUrl, // เพิ่ม URL ของภาพใน task
                          );
                          await widget.dbHelper.insertTask(newTask);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('เพิ่มงาน: $_title สำเร็จ!')),
                          );
                          Navigator.pop(context);
                        }
                      },
                      child: const Text('บันทึก'),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
