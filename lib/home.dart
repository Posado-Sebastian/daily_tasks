import 'package:flutter/material.dart';
import 'bottomsheet.dart';
import 'db_helper.dart';
import 'task.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 90,
        title: const Text('Home'),
        centerTitle: true,
      ),
      body: const Center(child: Text('Hello World!')),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            builder: (BuildContext context) {
              return const BottomSheetWidget();
            },
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}