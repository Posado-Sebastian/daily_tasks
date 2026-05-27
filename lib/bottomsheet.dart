import 'package:flutter/material.dart';
import 'db_helper.dart';
import 'models/task.dart';

class BottomSheetWidget extends StatefulWidget {
  final Task? task;

  const BottomSheetWidget({super.key, this.task});

  @override
  State<BottomSheetWidget> createState() => _BottomSheetWidgetState();
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
  DateTime? _selectedDate;
  ScheduleType _scheduleType = ScheduleType.weekDays;

  bool get _isEditing => widget.task != null;

  List<String> get _orderedSelectedDays {
    return _weekDays.where(_selectedDays.contains).toList();
  }

  String get _selectedDateLabel {
    if (_selectedDate == null) {
      return 'No date selected';
    }

    return '${_selectedDate!.month}/${_selectedDate!.day}/${_selectedDate!.year}';
  }

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      _titleController.text = widget.task!.title;
      _selectedDays.addAll(widget.task!.days);
      _selectedDate = Task.normalizeDate(widget.task!.specificDate);
      _scheduleType = _selectedDate == null
          ? ScheduleType.weekDays
          : ScheduleType.specificDate;
    }
  }

  Future<void> _pickSpecificDate() async {
    final now = DateTime.now();
    final initialDate = _selectedDate ?? now;
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 10),
    );

    if (pickedDate == null) {
      return;
    }

    setState(() {
      _scheduleType = ScheduleType.specificDate;
      _selectedDate = Task.normalizeDate(pickedDate);
      _selectedDays.clear();
    });
  }

  Future<void> _saveTask() async {
    if (_titleController.text.trim().isEmpty) {
      return;
    }

    if (_scheduleType == ScheduleType.weekDays && _selectedDays.isEmpty) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select at least one day')),
      );
      return;
    }

    if (_scheduleType == ScheduleType.specificDate && _selectedDate == null) {
      return;
    }

    final task = Task(
      id: widget.task?.id,
      title: _titleController.text.trim(),
      days: _scheduleType == ScheduleType.weekDays
          ? _orderedSelectedDays
          : const [],
      specificDate:
          _scheduleType == ScheduleType.specificDate ? _selectedDate : null,
      isActive: widget.task?.isActive ?? true,
    );

    if (_isEditing) {
      await DbHelper.updateTask(task);
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('task updated')));
    } else {
      await DbHelper.insertTask(task);
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('task added')));
    }

    Navigator.pop(context);
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
            const SizedBox(height: 16),
            SegmentedButton<ScheduleType>(
              segments: const [
                ButtonSegment<ScheduleType>(
                  value: ScheduleType.weekDays,
                  label: Text('Week days'),
                  icon: Icon(Icons.repeat),
                ),
                ButtonSegment<ScheduleType>(
                  value: ScheduleType.specificDate,
                  label: Text('Specific date'),
                  icon: Icon(Icons.event),
                ),
              ],
              selected: {_scheduleType},
              onSelectionChanged: (selection) {
                final nextType = selection.first;
                setState(() {
                  _scheduleType = nextType;
                  if (nextType == ScheduleType.weekDays) {
                    _selectedDate = null;
                  } else {
                    _selectedDays.clear();
                  }
                });
              },
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 44,
              child: _scheduleType == ScheduleType.weekDays
                  ? Row(
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
                    )
                  : SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: _pickSpecificDate,
                        icon: const Icon(Icons.event),
                        label: Text(_selectedDateLabel),
                      ),
                    ),
            ),
            const SizedBox(height: 12),
            if (_isEditing)
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        final scaffoldMessenger = ScaffoldMessenger.of(context);
                        final navigator = Navigator.of(context);
                        await DbHelper.deleteTask(widget.task!.id!);
                        if (!mounted) {
                          return;
                        }
                        final snackBar = SnackBar(
                          content: const Text('task deleted'),
                        );
                        scaffoldMessenger.showSnackBar(snackBar);
                        navigator.pop();
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
                      onPressed: _saveTask,
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
                  onPressed: _saveTask,
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

enum ScheduleType { weekDays, specificDate }
