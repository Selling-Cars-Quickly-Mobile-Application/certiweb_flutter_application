import 'package:flutter/material.dart';

class CalendarSelection {
  DateTime? selectedDateTime;
}

class CalendarComponent extends StatefulWidget {
  final void Function(CalendarSelection selection) onSelectionChanged;
  const CalendarComponent({super.key, required this.onSelectionChanged});

  @override
  State<CalendarComponent> createState() => _CalendarComponentState();
}

class _CalendarComponentState extends State<CalendarComponent> {
  final selection = CalendarSelection();
  final timeSlots = const [
    {'display': '9:00 AM', 'hour': 9},
    {'display': '11:00 AM', 'hour': 11},
    {'display': '1:00 PM', 'hour': 13},
    {'display': '3:00 PM', 'hour': 15},
    {'display': '5:00 PM', 'hour': 17}
  ];

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: selection.selectedDateTime ?? now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
      selectableDayPredicate: (d) => d.weekday >= DateTime.monday && d.weekday <= DateTime.friday,
    );
    if (picked != null) {
      final currentTime = selection.selectedDateTime?.hour ?? 9;
      final newDateTime = DateTime(picked.year, picked.month, picked.day, currentTime, 0);
      setState(() => selection.selectedDateTime = newDateTime);
      widget.onSelectionChanged(selection);
    }
  }

  void _selectTime(Map<String, dynamic> slot) {
    DateTime newDateTime;
    if (selection.selectedDateTime == null) {
      final now = DateTime.now();
      newDateTime = DateTime(now.year, now.month, now.day, slot['hour'], 0);
      if (newDateTime.weekday == DateTime.saturday) {
        newDateTime = newDateTime.add(const Duration(days: 2));
      } else if (newDateTime.weekday == DateTime.sunday) {
        newDateTime = newDateTime.add(const Duration(days: 1));
      }
      if (newDateTime.isBefore(now)) {
        newDateTime = newDateTime.add(const Duration(days: 1));
        while (newDateTime.weekday == DateTime.saturday || newDateTime.weekday == DateTime.sunday) {
          newDateTime = newDateTime.add(const Duration(days: 1));
        }
      }
    } else {
      newDateTime = DateTime(
        selection.selectedDateTime!.year,
        selection.selectedDateTime!.month,
        selection.selectedDateTime!.day,
        slot['hour'],
        0
      );
    }
    setState(() => selection.selectedDateTime = newDateTime);
    widget.onSelectionChanged(selection);
  }

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        color: const Color(0xFFEFF7ED),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Seleccione una fecha', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            OutlinedButton(onPressed: _pickDate, child: Text(selection.selectedDateTime == null ? 'Seleccione una fecha' : _fmt(selection.selectedDateTime!))),
            const SizedBox(height: 8),
            const Text('Solo días laborables (Lunes a Viernes)', style: TextStyle(color: Colors.grey, fontSize: 12)),
          ]),
        ),
      ),
      Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        color: const Color(0xFFEFF7ED),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Seleccione una hora', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ...timeSlots.map((slot) {
              final isSelected = selection.selectedDateTime != null && selection.selectedDateTime!.hour == slot['hour'];
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isSelected ? const Color(0xFF2E7D32) : Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(44),
                  ),
                  onPressed: () => _selectTime(slot),
                  child: Text(slot['display'] as String),
                ),
              );
            }),
            const SizedBox(height: 8),
            const Text('Disponible de Lunes a Viernes', style: TextStyle(color: Colors.grey, fontSize: 12)),
          ]),
        ),
      ),
    ]);
  }

  String _fmt(DateTime d) => '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
}