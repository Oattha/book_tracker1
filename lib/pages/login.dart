import 'package:flutter/material.dart';
import '../database/auth.dart';
import '../database/database_helper.dart';
import '../pages/product.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  String _email = '';
  String _passwd = '';

  late AnimationController _controller;
  late Animation<Color?> _colorAnimation;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwdController = TextEditingController();

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

  Future _showAlert(BuildContext context, String message) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            message,
            style: const TextStyle(fontSize: 16, color: Colors.pinkAccent),
          ),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(18.0)),
          ),
          actions: [
            ElevatedButton(
              child: const Text('ปิด'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.lightBlueAccent,
              ),
              onPressed: () {
                Navigator.pop(context);
              },
            )
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose(); // ไม่ลืม dispose controller
    _emailController.dispose(); // Dispose controller ของอีเมล
    _passwdController.dispose(); // Dispose controller ของรหัสผ่าน
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: AnimatedBuilder(
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
                padding: const EdgeInsets.all(36.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(
                      height: 155.0,
                      child: Text(
                        '👩‍🎓 เข้าสู่ระบบ',
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          color: Colors.deepPurpleAccent,
                        ),
                      ),
                    ),
                    const SizedBox(height: 45.0),
                    TextFormField(
                      controller: _emailController,
                      obscureText: false,
                      autofocus: true,
                      onChanged: (value) => _email = value,
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
                        hintText: "✉️ อีเมล",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(32.0),
                        ),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.7),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(32.0),
                          borderSide: const BorderSide(color: Colors.pinkAccent, width: 2.0),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(32.0),
                          borderSide: const BorderSide(color: Colors.pinkAccent, width: 2.0),
                        ),
                      ),
                    ),
                    const SizedBox(height: 25.0),
                    TextFormField(
                      controller: _passwdController,
                      obscureText: true,
                      onChanged: (value) => _passwd = value,
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
                        hintText: "🔒 รหัสผ่าน",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(32.0),
                        ),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.7),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(32.0),
                          borderSide: const BorderSide(color: Colors.pinkAccent, width: 2.0),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(32.0),
                          borderSide: const BorderSide(color: Colors.deepPurpleAccent, width: 2.0),
                        ),
                      ),
                    ),
                    const SizedBox(height: 35.0),
                    Material(
                      elevation: 5.0,
                      borderRadius: BorderRadius.circular(30.0),
                      color: Colors.deepPurpleAccent,
                      child: MaterialButton(
                        minWidth: MediaQuery.of(context).size.width,
                        padding: const EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
                        onPressed: () async {
                          await UserAuthentication()
                              .signInWithEmailAndPassword(_email, _passwd)
                              .then((res) {
                            if (res == true) {
                              Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => TaskScreen(dbHelper: DatabaseHelper()),
                              )); // เปลี่ยนจาก ProductScreen เป็น TaskScreen
                              setState(() {
                                _email = '';
                                _passwd = '';
                                _emailController.clear(); // ล้างค่าของอีเมล
                                _passwdController.clear(); // ล้างค่าของรหัสผ่าน
                              });
                            } else {
                              _showAlert(context, 'การเข้าสู่ระบบล้มเหลว');
                            }
                          });
                        },
                        child: const Text(
                          "เข้าสู่ระบบ",
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white, fontSize: 18),
                        ),
                      ),
                    ),
                    const SizedBox(height: 15.0),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
