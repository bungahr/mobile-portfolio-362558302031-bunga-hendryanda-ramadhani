import 'package:flutter/material.dart';

import 'data_page.dart';

class SuksesPage extends StatelessWidget {
  const SuksesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Sukses',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 90),

            const SizedBox(height: 20),

            const Text(
              'Data Berhasil Disimpan',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 12),

            const Text(
              'Terima kasih, data telah tersimpan.',
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 30),

            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const DataPage()),
                );
              },
              child: const Text('Data'),
            ),
          ],
        ),
      ),
    );
  }
}
