import 'package:flutter/material.dart';

import 'pages/home_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Belajar Navigator',
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      home: const HomePage(),
    );
  }
}

// import 'package:flutter/material.dart';

// import 'study_kasus/home_wisata.dart';

// void main() {
//   runApp(const StudyKasusApp());
// }

// class StudyKasusApp extends StatelessWidget {
//   const StudyKasusApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       title: 'Wisata Kampus',
//       theme: ThemeData(
//         useMaterial3: true,
//         colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF087FF5)),
//       ),
//       home: const HomeWisata(),
//     );
//   }
// }
