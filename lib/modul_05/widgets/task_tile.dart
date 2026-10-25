import 'package:flutter/material.dart';
import '../models/task.dart';

class TaskTile extends StatelessWidget {
  const TaskTile({super.key, required this.task, required this.onToggle});

  final Task task;
  final ValueChanged<Task> onToggle;

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
          style: TextStyle(
            decoration: task.done ? TextDecoration.lineThrough : null,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: <Widget>[
                Text(task.id),
                const SizedBox(width: 8),
                Text(task.course),
              ],
            ),
            if (tanggal != null)
              Row(
                children: [
                  Icon(Icons.access_time, size: 14, color: warna.primary),
                  const SizedBox(width: 4),
                  Text(
                    '${tanggal.day}/${tanggal.month}/${tanggal.year}',
                    style: TextStyle(color: warna.primary, fontSize: 12),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}