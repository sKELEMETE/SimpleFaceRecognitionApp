import 'package:flutter/material.dart';

import 'db_service.dart';

class StoragePage extends StatefulWidget {
  const StoragePage({super.key});

  @override
  State<StoragePage> createState() => _StoragePageState();
}

class _StoragePageState extends State<StoragePage> {
  List<Map<String, dynamic>> faces = [];

  @override
  void initState() {
    super.initState();
    refreshFaces();
  }

  Future<void> refreshFaces() async {
    final data = await DBService.instance.fetchAll();

    setState(() {
      faces = data;
    });
  }

  Future<void> deleteFace(int id) async {
    await DBService.instance.delete(id);

    refreshFaces();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Stored Faces'),
      ),
      body: faces.isEmpty
          ? const Center(
              child: Text('No faces stored'),
            )
          : ListView.builder(
              itemCount: faces.length,
              itemBuilder: (context, index) {
                final face = faces[index];

                return ListTile(
                  title: Text(face['name']),
                  subtitle: Text(
                    'ID: ${face['id']}',
                  ),
                  trailing: IconButton(
                    icon: const Icon(
                      Icons.delete,
                      color: Colors.red,
                    ),
                    onPressed: () {
                      deleteFace(face['id']);
                    },
                  ),
                );
              },
            ),
    );
  }
}