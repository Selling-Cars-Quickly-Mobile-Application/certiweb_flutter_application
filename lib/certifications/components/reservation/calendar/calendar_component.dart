import 'package:flutter/material.dart';

class CalendarSelection {
  DateTime? date;
  String? time; // HH:mm
}

class CalendarComponent extends StatefulWidget {
  final void Function(CalendarSelection selection) onSelectionChanged;
  const CalendarComponent({super.key, required this.onSelectionChanged});

  @override
  State<CalendarComponent> createState() => _CalendarComponentState();
}

class _CalendarComponentState extends State<CalendarComponent> {
  final selection = CalendarSelection();
  final timeSlots = const ['09:00', '11:00', '13:00', '15:00', '17:00'];

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now.subtract(const Duration(days: 0)),
      lastDate: now.add(const Duration(days: 365)),
      selectableDayPredicate: (d) {
        // Monday..Friday only
        return d.weekday >= DateTime.monday && d.weekday <= DateTime.friday;
      },
    );
    if (picked != null) {
      setState(() => selection.date = picked);
      widget.onSelectionChanged(selection);
    }
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
            const Text('Select a date', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            OutlinedButton(onPressed: _pickDate, child: Text(selection.date == null ? 'Select a date' : _fmt(selection.date!))),
            const SizedBox(height: 8),
            const Text('Only business days (Monday to Friday)', style: TextStyle(color: Colors.grey, fontSize: 12)),
          ]),
        ),
      ),
      Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        color: const Color(0xFFEFF7ED),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Select a time', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ...timeSlots.map((slot) {
              final isSelected = selection.time == slot;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isSelected ? const Color(0xFF2E7D32) : Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(44),
                  ),
                  onPressed: () {
                    setState(() => selection.time = slot);
                    widget.onSelectionChanged(selection);
                  },
                  child: Text(_toAmPm(slot)),
                ),
              );
            }),
            const SizedBox(height: 8),
            const Text('Available since Monday to Friday', style: TextStyle(color: Colors.grey, fontSize: 12)),
          ]),
        ),
      ),
    ]);
  }

  String _fmt(DateTime d) => '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  String _toAmPm(String hhmm) {
    final parts = hhmm.split(':');
    var h = int.parse(parts[0]);
    final m = parts[1];
    final suffix = h >= 12 ? 'PM' : 'AM';
    if (h == 0) h = 12; else if (h > 12) h -= 12;
    return '$h:${m} $suffix';
  }
}