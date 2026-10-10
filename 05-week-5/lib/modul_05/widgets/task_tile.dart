import 'package:flutter/material.dart';

import '../models/task.dart';

class TaskTile extends StatelessWidget {
  const TaskTile({super.key, required this.task, required this.onToggle});

  final Task task;
  final ValueChanged<Task> onToggle;

  String _namaPrioritas(int nilai) {
    switch (nilai) {
      case 1:
        return 'Tinggi';
      case 3:
        return 'Rendah';
      default:
        return 'Sedang';
    }
  }

  String _formatTanggal(DateTime tanggal) {
    return '${tanggal.day}/${tanggal.month}/${tanggal.year}';
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme warna = Theme.of(context).colorScheme;
    final DateTime? tanggal = Task.bacaTanggal(task);

    return Card(
      child: CheckboxListTile(
        value: task.done,
        onChanged: (_) => onToggle(task),
        controlAffinity: ListTileControlAffinity.leading,
        title: Text(
          task.title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            decoration: task.done ? TextDecoration.lineThrough : null,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Row(
            children: <Widget>[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: warna.secondaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text('Prioritas ${_namaPrioritas(task.prioritas)}'),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  task.course,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (tanggal != null) ...<Widget>[
                const SizedBox(width: 8),
                Text(_formatTanggal(tanggal)),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
