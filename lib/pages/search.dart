import 'package:flutter/material.dart';
import '../database/database_helper.dart';

class SearchProduct extends StatelessWidget {
  final DatabaseHelper dbHelper;

  const SearchProduct({Key? key, required this.dbHelper}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Tasks'),
      ),
      body: Center(
        child: const Text('มาในการอัปเดตครั้งหน้าครับ'),
      ),
    );
  }
}
