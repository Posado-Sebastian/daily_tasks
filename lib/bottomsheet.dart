import 'package:flutter/material.dart';
import 'db_helper.dart';
import 'task.dart';

class BottomSheetWidget extends StatefulWidget {
  final Task? task;

  const BottomSheetWidget({super.key, this.task});

  @override
  _BottomSheetWidgetState createState() => _BottomSheetWidgetState();
}

class _BottomSheetWidgetState extends State<BottomSheetWidget> {
  final List<String> _weekDays = const [
    'Su',
    'Mo',
    'Tu',
    'We',
    'Th',
    'Fr',
    'Sa',
  ];
  final Set<String> _selectedDays = <String>{};
  final TextEditingController _titleController = TextEditingController();

  bool get _isEditing => widget.task != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      _titleController.text = widget.task!.title;
      _selectedDays.addAll(widget.task!.days);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _isEditing ? 'Edit Task' : 'New Task',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _titleController,
              autofocus: false,
              decoration: const InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                for (final day in _weekDays)
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 3),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(500),
                        onTap: () {
                          setState(() {
                            if (_selectedDays.contains(day)) {
                              _selectedDays.remove(day);
                            } else {
                              _selectedDays.add(day);
                            }
                          });
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: _selectedDays.contains(day)
                                ? Theme.of(context).colorScheme.primary
                                : Theme.of(
                                    context,
                                  ).colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(500),
                          ),
                          child: Text(day, textAlign: TextAlign.center),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 20),
            if (_isEditing)
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        await DbHelper.deleteTask(widget.task!.id!);
                        final snackBar = SnackBar(
                          content: const Text('task deleted'),
                        );
                        ScaffoldMessenger.of(context).showSnackBar(snackBar);
                        if (context.mounted) Navigator.pop(context);
                      },
                      icon: const Icon(Icons.delete),
                      label: const Text('Delete'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        if (_titleController.text.trim().isEmpty) return;
                        final task = Task(
                          id: widget.task?.id,
                          title: _titleController.text.trim(),
                          days: _selectedDays.isEmpty
                              ? List.from(_weekDays)
                              : _selectedDays.toList(),
                          isActive: widget.task?.isActive ?? true,
                        );
                        await DbHelper.updateTask(task);
                        final snackBar = SnackBar(
                          content: const Text('task updated'),
                        );
                        ScaffoldMessenger.of(context).showSnackBar(snackBar);
                        if (context.mounted) Navigator.pop(context);
                      },
                      icon: const Icon(Icons.save),
                      label: const Text('Update'),
                    ),
                  ),
                ],
              )
            else
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    if (_titleController.text.trim().isEmpty) return;
                    final task = Task(
                      id: widget.task?.id,
                      title: _titleController.text.trim(),
                      days: _selectedDays.isEmpty
                          ? List.from(_weekDays)
                          : _selectedDays.toList(),
                      isActive: widget.task?.isActive ?? true,
                    );
                    await DbHelper.insertTask(task);
                    final snackBar = SnackBar(
                      content: const Text('task added'),
                    );
                    ScaffoldMessenger.of(context).showSnackBar(snackBar);
                    if (context.mounted) Navigator.pop(context);
                  },
                  icon: const Icon(Icons.save),
                  label: const Text('Save Task'),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
