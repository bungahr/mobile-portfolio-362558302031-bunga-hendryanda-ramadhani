import 'package:flutter/material.dart';

class DataPage extends StatelessWidget {
  const DataPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Data',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Data Mahasiswa',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 20),

            const Text('Nama: Bunga Hendryanda Ramadhani'),
            const SizedBox(height: 8),

            const Text('NIM: 362558302031'),
            const SizedBox(height: 8),

            const Text('Kelas: TRPL 2C'),

            const SizedBox(height: 30),

            ElevatedButton(
              onPressed: () {
                Navigator.popUntil(context, (route) => route.isFirst);
              },
              child: const Text('Exit'),
            ),
          ],
        ),
      ),
    );
  }
}
