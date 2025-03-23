import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../database/database_helper.dart';
import '../database/model.dart';
import 'search.dart';
import '../database/add_task.dart';
import '../database/edit_task.dart'; // เพิ่มการนำเข้า EditTaskScreen

class TaskScreen extends StatefulWidget {
  TaskScreen({Key? key, required this.dbHelper}) : super(key: key);
  final DatabaseHelper dbHelper;

  @override
  _TaskScreenState createState() => _TaskScreenState();
}

class _TaskScreenState extends State<TaskScreen> {
  List<Task2> tasks = []; // เปลี่ยนชื่อจาก products เป็น tasks

  Future<dynamic> _showConfirmDialog(BuildContext context, String confirmMessages) async =>
      showDialog(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(confirmMessages, style: const TextStyle(color: Colors.pinkAccent)),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context, true);
                },
                child: const Text('ใช่', style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.lightBlueAccent),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context, false);
                },
                child: const Text('ไม่', style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
              ),
            ],
          );
        },
      );

  void _deleteTask(String referenceId) {
    widget.dbHelper.deleteTaskById(referenceId); // ลบงานจาก Firestore
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddTaskPage(dbHelper: widget.dbHelper),
                ),
              );
            },
            icon: const Icon(Icons.add_task),
          ),
          IconButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => SearchProduct(dbHelper: widget.dbHelper),
                ),
              );
            },
            icon: const Icon(Icons.search),
          ),
        ],
        title: const Text('✨ Tasks ✨'),
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.pinkAccent.withOpacity(0.5), // สีเริ่มต้น
              Colors.lightBlueAccent.withOpacity(0.5), // สีสิ้นสุด
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: StreamBuilder<QuerySnapshot>(
          stream: widget.dbHelper.getStream(),
          builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            tasks.clear();
            for (var element in snapshot.data!.docs) {
              tasks.add(Task2.fromMap(element.data() as Map<String, dynamic>, element.id));
            }

            // จัดเรียง tasks ตามวันที่ครบกำหนด
            tasks.sort((a, b) => a.dueDate.compareTo(b.dueDate));

            return ListView.builder(
              itemCount: tasks.length,
              itemBuilder: (context, index) {
                return Dismissible(
                  key: UniqueKey(),
                  background: Container(color: Colors.blue),
                  secondaryBackground: Container(
                    color: const Color.fromARGB(255, 67, 39, 255),
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    child: const Icon(Icons.delete_rounded, color: Colors.white, size: 30),
                  ),
                  onDismissed: (direction) {
                    if (direction == DismissDirection.endToStart) {
                      _showConfirmDialog(context, 'ต้องการลบงานนี้?').then((confirmed) {
                        if (confirmed) {
                          _deleteTask(tasks[index].referenceId!); // ลบงานเมื่อยืนยัน
                        }
                      });
                    }
                  },
                  confirmDismiss: (direction) async {
                    if (direction == DismissDirection.endToStart) {
                      return await _showConfirmDialog(context, 'ต้องการลบงานนี้?');
                    }
                    return false;
                  },
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    elevation: 5,
                    margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                    color: Colors.lightBlue[50],
                    child: ListTile(
                      leading: Icon(
                        tasks[index].isCompleted ? Icons.check_circle : Icons.circle,
                        color: tasks[index].isCompleted ? Colors.green : Colors.grey,
                        size: 30,
                      ),
                      title: Text(
                        tasks[index].title,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.deepPurple),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('📅 วันครบกำหนด: ${tasks[index].dueDate.toLocal()}'),
                          Text('📊 ความก้าวหน้า: ${tasks[index].progress}%'),
                          Text(
                            tasks[index].isCompleted ? 'เสร็จแล้ว' : 'ยังไม่เสร็จ',
                            style: const TextStyle(color: Colors.pink, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min, // ปรับขนาดให้พอดีกับเนื้อหา
                        children: [
                          IconButton(
                            icon: Icon(Icons.edit, color: Colors.blue),
                            onPressed: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => EditTaskScreen(
                                    task: tasks[index],
                                    onUpdate: (updatedTask) {
                                      widget.dbHelper.updateTask(updatedTask);
                                      setState(() {
                                        tasks[index] = updatedTask;
                                      });
                                    },
                                    onDelete: (referenceId) {
                                      _deleteTask(referenceId);
                                      setState(() {
                                        tasks.removeAt(index); // ลบจากรายการที่แสดง
                                      });
                                    },
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                      onTap: () {
                        // สามารถมีฟังก์ชันการทำงานเมื่อกดที่ ListTile ได้
                      },
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
