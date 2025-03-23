import 'package:flutter/material.dart';
import '../database/model.dart';

class EditTaskScreen extends StatefulWidget {
  final Task2 task;
  final Function(Task2) onUpdate;
  final Function(String) onDelete; // เพิ่มฟังก์ชันสำหรับลบ

  EditTaskScreen({Key? key, required this.task, required this.onUpdate, required this.onDelete}) : super(key: key);

  @override
  _EditTaskScreenState createState() => _EditTaskScreenState();
}

class _EditTaskScreenState extends State<EditTaskScreen> with SingleTickerProviderStateMixin {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  DateTime? _dueDate;
  TimeOfDay _dueTime = TimeOfDay.now();
  int _progress = 0;

  late AnimationController _controller;
  late Animation<Color?> _colorAnimation;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task.title);
    _descriptionController = TextEditingController(text: widget.task.description);
    _dueDate = widget.task.dueDate;
    _dueTime = TimeOfDay.fromDateTime(widget.task.dueDate);
    _progress = widget.task.progress;

    // สร้าง AnimationController และ ColorTween
    _controller = AnimationController(
      duration: const Duration(seconds: 5),
      vsync: this,
    )..repeat(reverse: true);

    _colorAnimation = ColorTween(
      begin: Colors.pinkAccent.withOpacity(0.5),
      end: Colors.lightBlueAccent.withOpacity(0.5),
    ).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose(); // ไม่ลืม dispose controller
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _saveTask() {
    // คำนวณ isCompleted จาก progress
    bool isCompleted = _progress == 100;

    Task2 updatedTask = Task2(
      title: _titleController.text,
      description: _descriptionController.text,
      dueDate: DateTime(
        _dueDate!.year,
        _dueDate!.month,
        _dueDate!.day,
        _dueTime.hour,
        _dueTime.minute,
      ),
      // ส่ง isCompleted ที่คำนวณได้
      progress: _progress,
      referenceId: widget.task.referenceId,
      isCompleted: isCompleted, // ใช้ isCompleted ที่คำนวณแล้ว
    );

    widget.onUpdate(updatedTask);
    Navigator.pop(context);
  }

  Future<void> _selectDueDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _dueDate) {
      setState(() {
        _dueDate = picked;
      });
    }
  }

  Future<void> _selectDueTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _dueTime,
    );
    if (picked != null && picked != _dueTime) {
      setState(() {
        _dueTime = picked;
      });
    }
  }

  void _deleteTask() {
    widget.onDelete(widget.task.referenceId!); // เรียกใช้ฟังก์ชันลบ
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Task'),
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
                  ListTile(
                    title: Text('Due Date: ${_dueDate?.toLocal().toString().split(' ')[0] ?? 'Select a date'}'),
                    trailing: Icon(Icons.calendar_today),
                    onTap: () => _selectDueDate(context),
                  ),
                  ListTile(
                    title: Text('Due Time: ${_dueTime.format(context)}'),
                    trailing: Icon(Icons.access_time),
                    onTap: () => _selectDueTime(context),
                  ),
                  Text('ความคืบหน้า: $_progress%', style: TextStyle(fontSize: 16)),
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
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _saveTask,
                    child: Text('Save Changes'),
                  ),
                  ElevatedButton(
                    onPressed: _deleteTask, // ปุ่มลบงาน
                    child: Text('Delete Task', style: TextStyle(color: Colors.red)),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
