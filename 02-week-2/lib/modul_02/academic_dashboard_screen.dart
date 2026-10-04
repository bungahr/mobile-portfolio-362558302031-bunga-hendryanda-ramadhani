import 'package:flutter/material.dart';

import 'models/course.dart';
import 'widgets/course_card.dart';
import 'widgets/header_banner.dart';

class AcademicDashboardScreen extends StatefulWidget {
  const AcademicDashboardScreen({super.key});

  @override
  State<AcademicDashboardScreen> createState() =>
      _AcademicDashboardScreenState();
}

class _AcademicDashboardScreenState extends State<AcademicDashboardScreen> {
  final List<Course> _courses = Course.getSampleCourses();

  bool _isDarkMode = false;

  String _selectedCategory = 'Semua';

  int get totalSks => _courses.fold(0, (sum, course) => sum + course.sks);

  List<Course> get _filteredCourses {
    if (_selectedCategory == 'Semua') {
      return _courses;
    }

    return _courses
        .where((course) => course.category == _selectedCategory)
        .toList();
  }

  void _toggleDarkMode() {
    setState(() {
      _isDarkMode = !_isDarkMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0284C7),
          brightness: _isDarkMode ? Brightness.dark : Brightness.light,
        ),
        useMaterial3: true,
      ),
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Dashboard Akademik TRPL',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          backgroundColor: const Color(0xFF0284C7),
          foregroundColor: Colors.white,
          actions: [
            IconButton(
              icon: Icon(
                _isDarkMode
                    ? Icons.light_mode_rounded
                    : Icons.dark_mode_rounded,
              ),
              tooltip: _isDarkMode ? 'Mode Terang' : 'Mode Gelap',
              onPressed: _toggleDarkMode,
            ),
          ],
        ),

        body: LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth >= 600) {
              return Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 2,
                      child: SingleChildScrollView(
                        child: HeaderBanner(totalSks: totalSks),
                      ),
                    ),

                    const SizedBox(width: 20),

                    Expanded(
                      flex: 3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildCategoryFilter(),
                          const SizedBox(height: 16),

                          Expanded(
                            child: GridView.builder(
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    crossAxisSpacing: 16,
                                    mainAxisSpacing: 16,
                                    mainAxisExtent: 230,
                                  ),
                              itemCount: _filteredCourses.length,
                              itemBuilder: (context, index) {
                                return CourseCard(
                                  course: _filteredCourses[index],
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }

            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                HeaderBanner(totalSks: totalSks),
                const SizedBox(height: 16),

                _buildCategoryFilter(),

                const SizedBox(height: 16),

                Text(
                  'Mata Kuliah Semester 3 '
                  '(${_filteredCourses.length} Terdaftar)',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 12),

                ..._filteredCourses.map((course) => CourseCard(course: course)),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildCategoryFilter() {
    return Wrap(
      spacing: 8.0,
      runSpacing: 8.0,
      children: ['Semua', 'Teori', 'Praktikum'].map((category) {
        return ChoiceChip(
          label: Text(category),
          selected: _selectedCategory == category,
          onSelected: (selected) {
            if (selected) {
              setState(() {
                _selectedCategory = category;
              });
            }
          },
        );
      }).toList(),
    );
  }
}
